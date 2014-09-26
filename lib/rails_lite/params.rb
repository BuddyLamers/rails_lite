require 'uri'

class Params
  # Initialize merges params from
  # 1. query string
  # 2. post body
  # 3. route params
  attr_reader :params
  
  def initialize(req, route_params = {})
    @query_params = parse_www_encoded_form(req.query_string)
    @post_params = parse_www_encoded_form(req.body) unless parse_www_encoded_form(req.body).empty?
    @params = @query_params.merge!(@post_params.merge!(route_params))
    @permit = []
  end

  def [](key)
    @params[key]
  end

  def permit(*keys)
    keys.map { |key| @permit << key unless permitted?(key)}
  end

  def require(key)
    raise AttributeNotFoundError unless @params.keys.include?(key)
  end

  def permitted?(key)
    @permit.include?(key)
  end

  def to_s
    @params.to_json.to_s
  end

  class AttributeNotFoundError < ArgumentError; end;

  private
  # this should return deeply nested hash
  # argument format
  # user[address][street]=main&user[address][zip]=89436
  # should return
  # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
  def parse_www_encoded_form(www_encoded_form)
    return {} if www_encoded_form.nil?
    pieces = URI.decode_www_form(www_encoded_form)
    
    keys = []
    pieces.each { |piece| keys << parse_key(piece[0]) }
    # keys = [["user","address","street"], ["user", "address","zip"]]
    result = {}
    keys.each_with_index do |key_block, i|
      result[key_block.pop] = pieces[i].last
    end
    while keys[0].length > 0
      result = { keys[0].pop => result }
    end
    return result
  end

  # this should return an array
  # user[address][street] should return ['user', 'address', 'street']
  def parse_key(key)
    key.split(/\]\[|\[|\]/)
  end
end
