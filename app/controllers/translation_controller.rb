require 'json'

class TranslationController < ApplicationController
  THREAD_COUNT=50
  def index
  end

  def show
    mutex = Mutex.new
    translated_subtitle =[]
    subtitle = params['subtitle'].tempfile
    uploaded_file = SRT::File.parse(File.new(subtitle))

    THREAD_COUNT.times.map {
      Thread.new(uploaded_file.lines, translated_subtitle) do |lines, file|
        while line = mutex.synchronize { lines.pop }
          line.text.map! do |textline|
            translate(textline, 'pt', 'ru')
          end
          mutex.synchronize { file << line }
        end
      end
    }.each(&:join)

    translated_subtitle.sort_by!(&:sequence)

    @subtitle = translated_subtitle
  end

  private
  def translate(text, from, to)
    key = 'trnsl.1.1.20150529T044349Z.30d73f0b0ce39c4c.872ccc5273e71338dffcdb2345e016a2f0be6d15'
    uri = URI.parse(URI.encode("https://translate.yandex.net/api/v1.5/tr.json/translate?key=#{key}&lang=#{from}-#{to}&text=#{text}").strip)
    response = Net::HTTP.get_response(uri)
    response_body = response.body

    if response.is_a?(Net::HTTPSuccess)
      parsed = JSON.parse(response_body)
      return parsed['text'][0]
    else
      puts 'Erro na Tradução'
    end
  end
end
