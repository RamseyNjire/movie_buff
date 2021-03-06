def what_was_that_one_with(those_actors)
  # Find the movies starring all `those_actors` (an array of actor names).
  # Show each movie's title and id.
  Movie
  .select(:id, :title)
  .joins(:actors)
  .where('actors.name IN (?)', those_actors)
  .group(:id)
  .having('COUNT(actors.id) >= ?', those_actors.length)

end

def golden_age
  # Find the decade with the highest average movie score.
  Movie
    .select('AVG(score), (yr / 10) * 10 AS decade')
    .group('decade')
    .order('avg(score) DESC')
    .first
    .decade

end

def costars(name)
  # List the names of the actors that the named actor has ever
  # appeared with.
  # Hint: use a subquery

  # Actor
  # .joins(:movies)
  # .where('movies.id IN (?)',
  # (Movie.select(:id).joins(:actors).where('actors.name = ?', name)))
  # .where('actors.name != ?', name)
  # .distinct
  # .pluck(:name)

  subquery = Movie.select(:id).joins(:actors).where(actors: { name: name })

  Movie
    .joins(:actors)
    .where.not(actors: { name: name })
    .where(movies: { id: subquery })
    .distinct
    .pluck(:name)

end

def actor_out_of_work
  # Find the number of actors in the database who have not appeared in a movie

  # actors_with_appearances = Actor
  # .select(:id)
  # .joins(:movies)
  # .group(:id)

  # Actor
  # .select(:id)
  # .where.not(id: actors_with_appearances)
  # .count

  Actor
  .left_outer_joins(:movies)
  .where(castings: { movie_id: nil })
  .count

end

def starring(whazzername)
  # Find the movies with an actor who had a name like `whazzername`.
  # A name is like whazzername if the actor's name contains all of the
  # letters in whazzername, ignoring case, in order.

  # ex. "Sylvester Stallone" is like "sylvester" and "lester stone" but
  # not like "stallone sylvester" or "zylvester ztallone"

  name_matcher = whazzername.gsub!(/[^0-9A-Za-z]/, '').downcase.split("").map.with_index do |character, index|
    if index == 0
      '%' + character + '%'
    else
      character + '%'
    end
  end.join("")

  Movie
  .joins(:actors)
  .where('LOWER(actors.name) LIKE ?', name_matcher)

end

def longest_career
  # Find the 3 actors who had the longest careers
  # (the greatest time between first and last movie).
  # Order by actor names. Show each actor's id, name, and the length of
  # their career.

  Actor
  .select('actors.id, actors.name, (MAX(movies.yr) - MIN(movies.yr)) AS career')
  .joins(:movies)
  .group('actors.id, actors.name')
  .order('career DESC, actors.name')
  .limit(3)

end
