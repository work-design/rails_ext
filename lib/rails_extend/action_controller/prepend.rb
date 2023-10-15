module RailsExtend::ActionController
  module Prepend

    private
    def _prefixes
      # 支持在 views/:controller 目录下以 _:action 开头的子目录进一步分组，会优先查找该目录下文件
      # 支持在 views/:controller 目录下以 _base 开头的通用分组子目录
      pres = ["#{controller_path}/_#{params['action']}", "#{controller_path}/_base"]
      names = ["#{params[:business]}/#{params[:namespace]}"]
      namespaces = [params[:namespace]]

      super_class = self.class.superclass
      # 同名 controller, 向上级追溯
      while RailsExtend::Routes.find_actions(super_class.controller_path).include?(params['action'])
        pres.concat ["#{super_class.controller_path}/_#{params['action']}", "#{super_class.controller_path}/_base"]
        x = RailsExtend::Routes.controller_paths.dig(super_class.controller_path)
        names.append "#{x[:business]}/#{x[:namespace]}"
        namespaces.append x[:namespace] unless namespaces.include?(x[:namespace])
        super_class = super_class.superclass
      end
      # 可以在 controller 中定义 _prefixes 方法
      # super do |pres|
      #   pres + ['xx']
      # end
      if block_given?
        pres = yield pres
      end
      pres += super

      names.compact_blank!
      if names.size >= 2
        names[0...-1].zip(names[1..-1]).reverse_each do |before, after|
          base_con = "#{before}/base"
          if pres.exclude?(base_con)
            r = pres.index("#{after}/base")
            pres.insert(r, base_con) if r
          end
        end
      end

      namespaces.compact_blank!
      if namespaces.size >= 2
        namespaces[0...-1].zip(namespaces[1..-1]).reverse_each do |before, after|
          if pres.exclude?(before)
            r = pres.index(after)
            pres.insert(r, before) if r
          end
        end
      end

      if defined?(current_organ) && current_organ&.code.present?
        RailsExtend.config.override_prefixes.each do |pre|
          index = pres.index(pre)
          pres.insert(index, "#{current_organ.code}/views/#{pre}") if index
        end
        pres.prepend "#{current_organ.code}/views/#{controller_path}"
      end

      pres
    end

  end
end

ActiveSupport.on_load :action_controller do
  prepend RailsExtend::ActionController::Prepend
end
