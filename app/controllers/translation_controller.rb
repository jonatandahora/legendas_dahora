require 'json'

class TranslationController < ApplicationController
  THREAD_COUNT=65
  def index
  end

  def show
    mutex = Mutex.new
    translated_subtitle = SRT::File.new
    from = params['from']
    to = params['to']
    subtitle = params['subtitle'].tempfile
    uploaded_file = SRT::File.parse(File.new(subtitle))
    original_file = SRT::File.parse(File.new(subtitle))
    $filename = params['subtitle'].original_filename

    THREAD_COUNT.times.map {
      Thread.new(uploaded_file.lines, translated_subtitle.lines) do |lines, file|
        while line = mutex.synchronize { lines.pop }
          line.text.map! do |textline|
            translate_yandex(textline, from, to)
          end
          mutex.synchronize { file << line }
        end
      end
    }.each(&:join)

    translated_subtitle.lines.sort_by!(&:sequence)

    $translated = translated_subtitle
    @original = original_file

  end

  def download
    send_data $translated.to_s, :type=> 'application/x-subrip', :x_sendfile=>true, :filename => $filename
  end

  private
  def translate_microsoft(text, from, to)
    app_id = 'TbG-fYM3BuIfHrxKHRuOYI2ktCTs9hJlO-Soq6zCO-NA*'
    uri = URI.parse(URI.encode("https://api.microsofttranslator.com/v2/ajax.svc/TranslateArray2?appId=\"#{app_id}\"&texts=[#{text.to_json}]&from=\"#{from}\"&to=\"#{to}\"").strip)
    response = Net::HTTP.get_response(uri)
    response_body = response.body
    if response.is_a?(Net::HTTPSuccess)
      parsed = JSON.parse(response_body[3, response_body.length - 1])
      return parsed[0]['TranslatedText']
    else
      puts 'Erro na Tradução'
      return
    end
  end

  def translate_yandex(text, from, to)
    key = 'trnsl.1.1.20150529T044349Z.30d73f0b0ce39c4c.872ccc5273e71338dffcdb2345e016a2f0be6d15'
    uri = URI.parse(URI.encode("https://translate.yandex.net/api/v1.5/tr.json/translate?key=#{key}&lang=#{from}-#{to}&text=#{text}").strip)
    response = Net::HTTP.get_response(uri)
    response_body = response.body

    if response.is_a?(Net::HTTPSuccess)
      parsed = JSON.parse(response_body)
      return parsed['text'][0]
    else
      puts 'Erro na Tradução'
      return
    end
  end
end
