class GameController < ApplicationController
	def index
		# Just get the next tick state of the board
		@live_cells = play(params[:live_cells]) if params.has_key? :live_cells
		# Or render an start fresh new setup for the game
	end

	def new
		# Create a new game board and redirect to index page
		@width = params[:width]
		@height = params[:height]
		# TODO generate initial random number of live_cells from params[:live_cells_number]
		redirect_to :index
	end

	def destroy
		# Just destroy the game and start over again
		params.delete :live_cells
		redirect_to :index
	end

	private

	def play(live_cells)

		xs = live_cells.to_h
		ys = live_cells.to_h {|c| [c.last, c.first] }

		live_neighbours = -> do |x,y|
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

		minmax_x = live_cells.minmax {|a,b| a.first <=> b.first}
		minmax_y = live_cells.minmax {|a,b| a.last <=> b.last}

		lower_x = minmax_x.first - 1
		upper_x = minmax_x.last + 1
		lower_y = minmax_y.first - 1
		upper_y = minmax_y.last + 1

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