class Swearword < ApplicationRecord
	validates_uniqueness_of :word
	validates_presence_of :word, :tier
end
