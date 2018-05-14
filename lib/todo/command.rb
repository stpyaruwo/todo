
module Todo

  # @author nagami
  class Command

    def initialize(argv)
      @argv = argv
    end

    def self.run(argv)
      new(argv).execute

    end

    def execute
      options = Options.parse!(@argv)
      sub_command = options.delete(:command)

      DB.prepare
      begin
        tasks = case sub_command
        when 'create'
          create_task(options[:name], options[:content])
        when 'delete'
          delete_task(options[:id])
        when 'update'
          update_task(options.delete(:id), options)
        when 'list'
          find_tasks(options[:status])
        end
        puts tasks.class
        display_tasks(tasks)
      rescue => e
        abort "Error: #{e.message}"
      end

    end

    #作成
    def create_task(name, content)
      # タスク作成時のデフォルトのstatusはデフォルト値が使われNOT_YETとなる
      Task.create!(name: name, content: content).reload
    end

    #削除
    def delete_task(id)
      task = Task.find(id)
      task.destroy
    end

    #更新
    def update_task(id, attributes)
      #ステータスの変更
      if status_name = attributes[:status]
        attributes[:status] = Task::STATUS.fetch(status_name.upcase)
      end

      task = Task.find(id)
      task.update_attributes! attributes #hashを渡して更新する

      task.reload
    end

    #取得
    def find_tasks(status_name)
      all_tasks = Task.order('created_at DESC')

      if status_name
        status = Task::STATUS.fetch(status_name.upcase)
        all_tasks.status_is(status)
      else
        all_tasks
      end
    end


    #表示形式
    private
    def display_tasks(tasks)
      header = display_format('ID', 'Name', 'Content', 'Status')
      puts header
      puts '-' * header.size
      Array(tasks).each do |task|
        puts display_format(task.id, task.name, task.content, task.status_name)
      end
    end

    def display_format(id, name, content, status)
      name_length = 20 - full_width_count(name)
      content_length = 40 - full_width_count(content)
      [id.to_s.rjust(4), name.ljust(name_length), content.ljust(content_length), status.ljust(8)].join(' | ')
    end

    def full_width_count(string)
      string.each_char.select{|char| !(/[ -~｡-ﾟ]/.match(char)) }.count
    end

  end
end
