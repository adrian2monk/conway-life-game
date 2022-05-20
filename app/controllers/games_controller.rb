class GamesController < ApplicationController

	def index
		@width = session[:width]
		@height = session[:height]
		# Just get the next tick state of the board
		@live_cells = play(params.fetch(:live_cells, {}).permit!.to_h.to_a) if params.has_key? :live_cells
		# Or render an start fresh new setup for the game
		if @width.present? && @height.present? && @live_cells.present?
			board_cells = []
			@width.times do |i|
				@height.times do |j|
					board_cells << [i, j]
				end
			end
			@board = board_cells.difference(@live_cells).map {|c| {x: c.first, y: c.last, alive: false}} + @live_cells.map {|c| {x: c.first, y: c.last, alive: true}} 
			@board.sort! {|a,b| a[:x] == b[:y] ? a[:x] <=> b[:x] : a[:y] <=> b[:y]}
		end
	end

	def create 
		# Create a new game board and redirect to index page
		width = params[:width].to_i
		height = params[:height].to_i
		# Generate initial random number of live_cells from params[:live_cells_number] 
		# WARN: may be collisions and you end up with less generated cells than you think
		live_cells = Array.new(params[:live_cells_number].to_i) {[rand(width), rand(height)]}
		session[:width] = width
		session[:height] = height
		redirect_to action: "index", live_cells: live_cells.uniq.to_h
	end

	private	

	def play(live_cells)

		xs = live_cells.to_h {|c| [c.last.to_i, c.first.to_i] }
		ys = live_cells.to_h {|c| [c.last.to_i, c.first.to_i] }

		live_neighbours = lambda do |x,y|
			count = 0
			count += 1 if xs.has_key?(x - 1) && xs.has_key?(y - 1)
			count += 1 if xs.has_key?(x - 1) && xs.has_key?(y)
			count += 1 if xs.has_key?(x) && xs.has_key?(y - 1)
			count += 1 if xs.has_key?(x + 1) && xs.has_key?(y + 1)
			count += 1 if xs.has_key?(x + 1) && xs.has_key?(y)
			count += 1 if xs.has_key?(x) && xs.has_key?(y + 1)
			count += 1 if xs.has_key?(x - 1) && xs.has_key?(y + 1)
			count += 1 if xs.has_key?(x + 1) && xs.has_key?(y - 1)
			count
		end

		minmax_x = live_cells.map {|c| c.first.to_i}.minmax
		minmax_y = live_cells.map {|c| c.last.to_i}.minmax

		lower_x = minmax_x.first.to_i > 0 ? minmax_x.first.to_i - 1 : 0
		upper_x = minmax_x.last.to_i + 1
		lower_y = minmax_x.first.to_i > 0 ? minmax_y.first.to_i - 1 : 0
		upper_y = minmax_y.last.to_i + 1

		# TODO optimize this latter to use just only neighboors cells and not the entire square
		new_cells = []
		(lower_x..upper_x).each do |i|
			(lower_y..upper_y).each do |j|
				neighbours_count = live_neighbours.call(i, j)	
				if xs.has_key?(i) && ys.has_key?(j) # Any live cell with two or three live neighbours survives
					new_cells << [i, j] if neighbours_count == 2 || neighbours_count == 3	
				else # Any dead cell with three live neighbours becomes a live cell
					new_cells << [i, j] if neighbours_count == 3
				end
			end
		end

		new_cells.sort
	end

end