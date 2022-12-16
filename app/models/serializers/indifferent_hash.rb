class Serializers::IndifferentHash
  def self.load(value)
    HashWithIndifferentAccess.new(value)
  end

  def self.dump(obj)
    return JSON.parse(obj) if obj.is_a?(String) rescue nil
    obj
  end
end
