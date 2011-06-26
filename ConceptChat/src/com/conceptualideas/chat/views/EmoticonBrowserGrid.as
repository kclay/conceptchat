package com.conceptualideas.chat.views
{


	import com.conceptualideas.chat.utils.Grid;

	import flash.events.Event;

	import mx.containers.Canvas;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.IStyleManager2;
	import mx.styles.StyleManager;


	[Style(name="cellPadding", type="Number")]
	[Style(name="rows", type="Number")]
	[Style(name="columns", type="Number")]

	public class EmoticonBrowserGrid extends Canvas
	{
		private var _cellWidth:Number;
		private var _cellHeight:Number;
		private var _emoticons:Array;

		private var _totalPages:int = 0;
		private var _amountPerPage:int
		private var _grid:Grid
		private var _currentPage:int = 0;
		private var _emoticonChanged:Boolean = false;
		private var _currentPageChanged:Boolean = false;

		private var _inMiddlePages:Boolean = false;

		private var items:Vector.<EmoticonBrowserGridItem> = new Vector.<EmoticonBrowserGridItem>();

		private var gridItemStyle:CSSStyleDeclaration

		private var numOfColumns:Number = NaN
		private var numOfRows:Number = NaN;
		private var deminsionsCaculated:Boolean = false;



		public function EmoticonBrowserGrid()
		{
			super();

			var styleManager:IStyleManager2 = StyleManager.getStyleManager(this.moduleFactory);
			gridItemStyle = styleManager.getStyleDeclaration("com.conceptualideas.chat.views.EmoticonBrowserGridItem");
			if (!gridItemStyle)
			{

				gridItemStyle = new CSSStyleDeclaration();
				gridItemStyle.defaultFactory = function():void{
					this.borderColor = 0xCCCCCC;
					this.borderStyle = 'solid';
					this.borderThickness = 1;
					this.cornerRadius = 5;
					this.backgroundAlpha = 0;
					this.maxWidth = 42;
					this.maxHeight = 42;
					this.maxImageHeight = 40;
					this.maxImageWidth = 40;
				}
			}


		}

		private function caculateCellDimensions():void
		{


			var currentHeight:Number = height;
			var currentWidth:Number = width;
			if (!currentHeight)
				return;


			var padding:Number = (getStyle("cellPadding") || 5) * 2
			var cellWidth:Number = gridItemStyle.getStyle("maxWidth");
			numOfColumns = numOfRows = NaN;
			if (isNaN(cellWidth))
			{
				numOfColumns = getStyle("columns");
				cellWidth = Math.ceil((currentWidth / numOfColumns) - padding);
			}

			var cellHeight:Number = gridItemStyle.getStyle("maxHeight");
			if (isNaN(cellHeight))
			{
				numOfRows = getStyle("rows")
				cellHeight = Math.ceil((currentHeight / getStyle("rows")) - padding);
			}
			if (isNaN(numOfColumns))
			{
				numOfColumns = int(currentWidth / (cellWidth + padding));
				numOfRows = int(currentHeight / (cellHeight + padding));

			}


			_grid = new Grid(numOfColumns, numOfRows, cellHeight, cellWidth, 0, 0);
			deminsionsCaculated = true;
			caculatePages();

		}

		override protected function createChildren():void
		{
			super.createChildren();
		}

		public function set emoticons(value:Array):void
		{
			_emoticons = value;
			_emoticonChanged = true;

			invalidateProperties();


		}

		override protected function commitProperties():void
		{
			super.commitProperties();
			if (_emoticonChanged)
			{

				_emoticonChanged = false;

				caculatePages();
				caculateCellDimensions();

				currentPage = 1;
			}

		}

		[Bindable(event="totalPagesChanged")]
		public function get totalPages():int
		{
			return _totalPages;
		}

		public function set currentPage(page:int):void
		{


			if (_currentPage != page)
			{

				if (page < 1 || page > _totalPages)
					return;


				_currentPage = page;

				_currentPageChanged = true;


				invalidateDisplayList();


				dispatchEvent(new Event("currentPageChanged"));

			}


		}

		[Bindable(event="currentPageChanged")]
		public function get currentPage():int
		{
			return _currentPage;
		}

		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);

			if (_currentPageChanged)
			{

				clearEmoticons();
				loadEmoticons();
				_currentPageChanged = false;
			}
		}

		private function clearEmoticons():void
		{
			var item:EmoticonBrowserGridItem;
			while (items.length)
			{
				item = items.shift();
				addElement(item);
				item.destory();
				item = null;
			}


		}

		private function loadEmoticons():void
		{

			if (!deminsionsCaculated)
				caculateCellDimensions();
			var item:EmoticonBrowserGridItem;
			var itemWidth:Number = _grid.cellWidth;
			var itemHeight:Number = _grid.cellHeight;
			var currentPos:int = (_amountPerPage * (_currentPage - 1));
			var endPos:int = (_amountPerPage * _currentPage);
			var i:int = 0;
			var total:int = _emoticons.length;
			var padding:Number = (getStyle("cellPadding") || 0) * 2
			var row:int = 0;
			var columns:Number = numOfColumns;
			for (; currentPos < endPos; currentPos++)
			{

				if (currentPos < total)
				{

					item = new EmoticonBrowserGridItem(_emoticons[currentPos].image, _emoticons[currentPos].text, _emoticons[currentPos].name);
					// Set the width and height so we can have correct size borders
					item.width = itemWidth;
					item.height = itemHeight;
					item.x = _grid[i].x + ((i % columns) * padding);
					if (!(i % columns))
					{
						row++;
					}
					item.y = _grid[i].y + ((row - 1) * padding);
					addElement(item);
					i++;
					items.push(item);
				}
			}

		}

		private function caculatePages():void
		{

			_amountPerPage = numOfRows * numOfColumns;
			_totalPages = Math.ceil(_emoticons.length / _amountPerPage) || 1;
			dispatchEvent(new Event("totalPagesChanged"));

		}


	}
}