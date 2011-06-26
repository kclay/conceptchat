package com.conceptualideas.chat.utils{
    /**
    * ...
    * @author Conceptual Ideas 2008
    */
    dynamic public class Grid extends Array{
        private var _cols:Number;
        private var _rows:Number;
		private var _cellHeight:Number
		private var _cellWidth:Number
		
        public function Grid (cols : Number , rows : Number , cellHeight : Number , cellWidth : Number , x : Number , y : Number):void{
            _cols = cols;
            _rows = rows;
			_cellWidth = cellWidth;
			_cellHeight = cellHeight;
            var numCells : Number = cols * rows;
            var curx : Number = x;
            for (var i:Number = 0; i < numCells; i++){
                this [i] ={
                    x : curx , y : y
                };
                curx += cellWidth;
                if ( !((i + 1) % cols)){
                    curx = x;
                    y += cellHeight;
                }
            }
        }
        //
        /**
        * The shuffle method will return the array of grid coordinates in a random order.
        *
        * @usage myGrid.shuffle()
        * @return  Void
        */
        public function shuffle () : void{
            var len : Number = this.length;
            var temp : Object = new Object ();
            for (var i:Number = 0; i < len; i++){
                var rand : Number = Math.floor (Math.random () * len);
                temp = this [i];
                this [i] = this [rand];
                this [rand] = temp;
            }
        }
        // Getters
        public function get columns():Number{
            return _cols;
        }
        public function get rows():Number{
            return _rows;
        }
		
		public function get cellHeight():Number { return _cellHeight; }
		
		public function get cellWidth():Number { return _cellWidth; }
    }
}
