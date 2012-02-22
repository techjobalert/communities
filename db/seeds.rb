# -*- coding: utf-8 -*-
puts "[START] DATABASE-SEED"

def get_stored_value(val)
  if val.in?(["true", "false"])
    eval(val)
  elsif val.to_i
    val.to_i
  else
    val
  end
end

#Settings
{ :comments_pre_moderation              => [false,  'comments pre moderation'],
  :items_pre_moderation                 => [false,  'items premoderation'],
  :show_search_results_per_page         => [12,     'show search results per page']
}.each do |key, value|
  s = Settings.find_by_key(key)
  def_text = "'#{key}' = #{value[0]} (#{value[1]})"
  attributes = {:key => key, :value => value[0].to_s, :description => value[1]}
  if s
    val = get_stored_value(s.value)
    if val == value[0] and s.description == value[1]
      puts "[exist] #{def_text}"
    else 
      s.update_attributes!(attributes)
      puts "[CHANGED] #{def_text}"
    end
  else
    Settings.create!(attributes)
    puts "[NEW] #{def_text}"
  end
end

puts "[FINISH] DATABASE-SEED"
