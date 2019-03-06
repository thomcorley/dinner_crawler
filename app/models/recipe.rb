class Recipe < ApplicationRecord
	AMP_REGEX = /\/amp([^a-zA-Z]|$|\s)/
	has_many :ingredients, dependent: :destroy
	has_many :instructions, dependent: :destroy

	validates_uniqueness_of :recipe_url 

	before_save :deduplicate_recipes_with_amp_versions

	class AmpRecipeDetectedError < StandardError 
		def message
			"Alternative AMP recipe detected, destroying self in favour of it"
		end
	end

	def deduplicate_recipes_with_amp_versions
		if is_amp?
			recipes = duplicate_recipes
			
			if recipes.any?
				recipes.each(&:destroy)
				Rails.logger.info("Other non-amp recipe(s) detected; removing")
			end
		else
			recipes = duplicate_amp_recipes

			if recipes.any?
				self.destroy
				raise AmpRecipeDetectedError
			end
		end
	end

	private

	# Assuming that another recipe with the same title from the same website is the same recipe
	def duplicate_amp_recipes
		base_url = URI.parse(recipe_url).host
		Recipe.where(title: title).where("recipe_url LIKE '%#{base_url}%'").where("recipe_url LIKE '%/amp%'")
	end

	def duplicate_recipes
		stripped_url = recipe_url.gsub(AMP_REGEX, "/").chomp("/")
		Recipe.where(title: title).where("recipe_url LIKE '%#{stripped_url}%'")
	end

	def is_amp?
		recipe_url.match?(AMP_REGEX)
	end
end