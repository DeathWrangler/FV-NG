package Display
{
   import Classes.EmbeddedArt;
   import Engine.Managers.SoundManager;
   import fl.motion.easing.Back;
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.filters.BitmapFilterQuality;
   import flash.filters.GlowFilter;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.utils.Timer;
   import flash.utils.getDefinitionByName;
   import gs.TweenLite;
   
   public class ActionMultiButton extends ActionButton
   {
      
      public static const PADDING_TOP:int = 4;
      
      public static const PADDING_LEFT:int = 0;
      
      public static const PADDING_BETWEEN_ICONS_X:int = 10;
      
      public static const SPRITE_OFFSET:int = 4;
      
      public static const ICON_OFFSET:int = 8;
      
      public static const MENU_OFFSET:int = 10;
      
      public static const CLOSE_MENU_DELAY:int = 250;
      
      public static const DEFAULT_ICON_SIZE:int = 50;
      
      public static const MAX_ROWS:int = 7;
      
      public static const MAX_COLUMNS:int = 2;
      
      protected var m_getItems:Function;
      
      protected var m_background:Bitmap;
      
      protected var m_items:Array = [];
      
      protected var m_menuSprite:Sprite = new Sprite();
      
      protected var m_arrowSprite:DisplayObject;
      
      protected var m_displayMenuOnRollover:Boolean;
      
      protected var m_yOffset:int;
      
      protected var m_timer:Timer;
      
      protected var m_selectedItem:Object;
      
      public function ActionMultiButton(asset:Class, getItemsCallback:Function, yOffset:int, toggle:Boolean = true, displayMenuOnRollover:Boolean = false)
      {
         super(asset,"top",true,toggle);
         this.addEventListener(MouseEvent.CLICK,this.onClick,false,0,true);
         this.addEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
         this.m_displayMenuOnRollover = displayMenuOnRollover;
         this.m_getItems = getItemsCallback;
         this.m_arrowSprite = new EmbeddedArt.hud_contextual_arrow();
         this.m_arrowSprite.x = this.width - 24;
         this.m_arrowSprite.y = 2;
         this.m_arrowSprite.visible = false;
         this.addChild(this.m_arrowSprite);
         this.m_yOffset = yOffset;
         this.updateItems();
      }
      
      protected function onClick(event:MouseEvent) : void
      {
         if(!this.isMenuShown())
         {
            if(!Global.ui.getActionMenu().locked)
            {
               Global.ui.getActionMenu().setDefaultGameMode();
               this.showMenu();
            }
         }
         else if(!this.m_displayMenuOnRollover)
         {
            this.hideMenu();
         }
         else
         {
            this.m_selectedItem.onClick();
         }
         if(!Global.ui.getActionMenu().locked)
         {
            toggle();
         }
         event.stopImmediatePropagation();
         event.stopPropagation();
      }
      
      override protected function onRollOut(event:MouseEvent) : void
      {
         super.onRollOut(event);
         if(this.m_displayMenuOnRollover)
         {
            this.timedHideMenu();
         }
      }
      
      override protected function onRollOver(event:MouseEvent) : void
      {
         var totalItems:int = 0;
         super.onRollOver(event);
         this.killHideMenuTimer();
         if(this.m_displayMenuOnRollover && !this.isMenuShown())
         {
            totalItems = this.getTotalItems();
            if(totalItems)
            {
               this.m_items = this.m_getItems();
               this.updateItemsArrayFormat();
            }
            if(totalItems > 1)
            {
               this.showMenu();
            }
         }
      }
      
      private function updateItemsArrayFormat() : void
      {
         var oldArray:Array = null;
         var oldArrayLength:int = 0;
         var index:int = 0;
         var totalRows:int = 0;
         var totalCols:int = 0;
         if(Boolean(this.m_items) && this.m_items.length > 0)
         {
            if(!(this.m_items[0] is Array))
            {
               if(this.m_items.length > MAX_ROWS)
               {
                  this.reflowItemsArray(this.m_items);
               }
               else
               {
                  oldArray = this.m_items;
                  oldArrayLength = int(oldArray.length);
                  this.m_items = new Array();
                  for(index = 0; index < oldArrayLength; index++)
                  {
                     this.m_items[index] = new Array();
                     this.m_items[index][0] = oldArray[index];
                  }
               }
            }
            else
            {
               totalRows = this.getTotalItemRows();
               totalCols = this.getTotalItemCols();
               if(totalRows > MAX_ROWS || totalCols > MAX_COLUMNS)
               {
                  this.reflowItemsArray(this.getItemsAsFlatArray());
               }
            }
         }
      }
      
      private function reflowItemsArray(items:Array) : void
      {
         var rowIndex:int = 0;
         var colIndex:int = 0;
         var numItems:int = int(items.length);
         this.m_items = new Array();
         for(var i:int = 0; i < numItems; i++)
         {
            rowIndex = i / MAX_COLUMNS;
            colIndex = i % MAX_COLUMNS;
            if(colIndex == 0)
            {
               this.m_items[rowIndex] = new Array();
            }
            this.m_items[rowIndex][colIndex] = items[i];
         }
      }
      
      private function getItemsAsFlatArray() : Array
      {
         var row:Array = null;
         var value:Object = null;
         var result:Array = new Array();
         for each(row in this.m_items)
         {
            for each(value in row)
            {
               result.push(value);
            }
         }
         return result;
      }
      
      public function updateItems(forceIconChange:Boolean = false) : void
      {
         var numCols:int = 0;
         var col:int = 0;
         var item:Object = null;
         this.m_items = this.m_getItems();
         this.updateItemsArrayFormat();
         var totalItems:int = 0;
         var numToggle:int = 0;
         var clickItem:Object = null;
         var numRows:int = int(this.m_items.length);
         for(var row:int = 0; row < numRows; row++)
         {
            numCols = int(this.m_items[row].length);
            for(col = 0; col < numCols; col++)
            {
               item = this.m_items[row][col];
               totalItems++;
               if(item.clickOnly != true)
               {
                  numToggle++;
                  clickItem = item;
               }
            }
         }
         if((numToggle == 1 || forceIconChange) && clickItem != null)
         {
            this.setSelectedItem(clickItem);
         }
         this.m_arrowSprite.visible = totalItems > 1;
      }
      
      public function showMenu(resetMode:Boolean = false, isMasteryReductionTutorial:Boolean = false) : void
      {
         var format:TextFormat = null;
         var numRows:int = 0;
         var row:int = 0;
         var lastRow:Array = null;
         var numCols:int = 0;
         var col:int = 0;
         var item:Object = null;
         var iconHeight:int = 0;
         var iconWidth:int = 0;
         var itemSprite:FarmGameSprite = null;
         var textField:TextField = null;
         var slotIcon:DisplayObject = null;
         var arrowSprite:DisplayObject = null;
         this.updateItems();
         var totalItems:int = this.getTotalItems();
         if(totalItems > 1)
         {
            this.drawBg();
            format = new TextFormat();
            format.font = "Merkin2";
            format.color = 6306067;
            format.align = "center";
            format.size = 10;
            numRows = int(this.m_items.length);
            for(row = 0; row < numRows; row++)
            {
               numCols = int(this.m_items[row].length);
               for(col = 0; col < numCols; col++)
               {
                  item = this.m_items[row][col];
                  iconHeight = 0;
                  iconWidth = 0;
                  if(item.sprite)
                  {
                     itemSprite = item.sprite;
                     iconHeight = itemSprite.height;
                     iconWidth = itemSprite.width;
                  }
                  else
                  {
                     itemSprite = new FarmGameSprite();
                  }
                  if(item.toolTip)
                  {
                     itemSprite.toolTip = item.toolTip;
                  }
                  textField = new TextField();
                  textField.text = item.text;
                  textField.defaultTextFormat = format;
                  textField.setTextFormat(format);
                  textField.width = this.m_background.width;
                  textField.wordWrap = false;
                  textField.embedFonts = true;
                  textField.selectable = false;
                  textField.autoSize = TextFieldAutoSize.CENTER;
                  textField.cacheAsBitmap = true;
                  itemSprite.addChild(textField);
                  if(item.icon)
                  {
                     if(item.icon is Loader)
                     {
                        if((item.icon as Loader).content != null)
                        {
                           slotIcon = (item.icon as Loader).content;
                        }
                        else
                        {
                           slotIcon = item.icon;
                           slotIcon.width = slotIcon.height = DEFAULT_ICON_SIZE;
                        }
                     }
                     else
                     {
                        slotIcon = new item.icon();
                     }
                     slotIcon.x = this.m_background.width - slotIcon.width >> 1;
                     slotIcon.y = ActionMultiButton.ICON_OFFSET;
                     slotIcon.cacheAsBitmap = true;
                     itemSprite.addChild(slotIcon);
                     iconHeight = slotIcon.height;
                     iconWidth = slotIcon.width;
                  }
                  itemSprite.x = PADDING_LEFT + (iconWidth + PADDING_BETWEEN_ICONS_X) * col - (numCols - 1) * ((iconWidth + PADDING_BETWEEN_ICONS_X) * 0.5);
                  itemSprite.y = ActionMultiButton.SPRITE_OFFSET + (iconHeight + PADDING_TOP) * row + PADDING_TOP;
                  if(!isMasteryReductionTutorial)
                  {
                     itemSprite.addEventListener(MouseEvent.CLICK,this.onMenuItemClick);
                     itemSprite.addEventListener(MouseEvent.ROLL_OVER,this.onMenuItemRollOver);
                     itemSprite.addEventListener(MouseEvent.ROLL_OUT,this.onMenuItemRollOut);
                  }
                  else if(item.isMastery)
                  {
                     itemSprite.addEventListener(MouseEvent.CLICK,this.onMenuItemClick);
                     itemSprite.addEventListener(MouseEvent.ROLL_OVER,this.onMenuItemRollOver);
                     itemSprite.addEventListener(MouseEvent.ROLL_OUT,this.onMenuItemRollOut);
                     arrowSprite = new EmbeddedArt.bouncing_arrow() as DisplayObject;
                     arrowSprite.x = this.x + this.width;
                     arrowSprite.y = this.y - 120;
                     arrowSprite.scaleX = 1;
                     arrowSprite.scaleY = 1;
                     arrowSprite.height = this.height;
                     arrowSprite.visible = true;
                     itemSprite.addChild(arrowSprite);
                  }
                  itemSprite.id = row + ":" + col;
                  this.m_menuSprite.addChild(itemSprite);
               }
            }
            Global.stage.addChild(this.m_menuSprite);
            this.m_menuSprite.cacheAsBitmap = true;
            this.m_menuSprite.alpha = 0;
            this.m_menuSprite.y += this.m_yOffset;
            TweenLite.to(this.m_menuSprite,0.5,{
               "alpha":1,
               "y":"100",
               "ease":Back.easeOut
            });
            if(!resetMode)
            {
               SoundManager.playSound("expandMenu");
            }
            if(!isMasteryReductionTutorial)
            {
               Global.stage.addEventListener(MouseEvent.CLICK,this.onStageClick,false,3);
            }
            lastRow = this.m_items[this.m_items.length - 1];
            this.setSelectedItem(lastRow[lastRow.length - 1]);
         }
         else if(!resetMode && totalItems == 1)
         {
            if(this.m_items[0][0].onClick != null)
            {
               this.m_items[0][0].onClick();
            }
         }
      }
      
      private function onStageClick(event:Event) : void
      {
         this.hideMenu();
         event.stopImmediatePropagation();
         event.stopPropagation();
      }
      
      protected function onMenuItemClick(event:Event) : void
      {
         var sprite:FarmGameSprite = event.currentTarget as FarmGameSprite;
         var rowCol:Array = sprite.id.split(":");
         var item:Object = this.m_items[rowCol[0]][rowCol[1]];
         if(item)
         {
            if(item.clickOnly != true)
            {
               this.setSelectedItem(item);
            }
            if(item.onClick)
            {
               if(item.passItemDataToCallback)
               {
                  item.onClick(item);
               }
               else
               {
                  item.onClick();
               }
            }
            this.hideMenu();
         }
      }
      
      protected function setSelectedItem(item:Object) : void
      {
         var ldr:Loader = null;
         if(this.m_selectedItem != item)
         {
            this.m_selectedItem = item;
            if(item.icon is Class)
            {
               setIcon(new item.icon());
            }
            else if(item.icon is Loader)
            {
               ldr = item.icon as Loader;
               if(ldr.content != null && ldr.content is Bitmap)
               {
                  setIcon(new Bitmap((ldr.content as Bitmap).bitmapData));
               }
               else
               {
                  ldr.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onSelectedIconLoad,false,0,true);
                  setIcon(ldr);
               }
            }
            this.toolTip = item.text;
            this.m_arrowSprite.parent.setChildIndex(this.m_arrowSprite,this.m_arrowSprite.parent.numChildren - 1);
         }
      }
      
      protected function onSelectedIconLoad(event:Event) : void
      {
         var ldr:Loader = event.target.loader as Loader;
         if(Boolean(ldr.content) && ldr.content is Bitmap)
         {
            if(this.m_selectedItem.icon == ldr)
            {
               setIcon(new Bitmap((ldr.content as Bitmap).bitmapData));
            }
            this.m_arrowSprite.parent.setChildIndex(this.m_arrowSprite,this.m_arrowSprite.parent.numChildren - 1);
         }
         ldr.contentLoaderInfo.removeEventListener(Event.COMPLETE,this.onSelectedIconLoad,false);
      }
      
      protected function onMenuItemRollOver(event:Event) : void
      {
         var mouseOverGlow:GlowFilter = null;
         var item:Sprite = event.currentTarget as Sprite;
         if(item)
         {
            mouseOverGlow = new GlowFilter();
            mouseOverGlow.blurX = mouseOverGlow.blurY = 1.3;
            mouseOverGlow.color = 16766607;
            mouseOverGlow.alpha = 1;
            mouseOverGlow.quality = BitmapFilterQuality.HIGH;
            mouseOverGlow.strength = 30;
            item.filters = [mouseOverGlow];
         }
         this.killHideMenuTimer();
      }
      
      protected function onMenuItemRollOut(event:Event) : void
      {
         var item:Sprite = event.currentTarget as Sprite;
         if(item)
         {
            item.filters = [];
         }
         if(this.m_displayMenuOnRollover)
         {
            this.timedHideMenu();
         }
      }
      
      public function hideMenu() : void
      {
         var itemSprite:Sprite = null;
         if(this.m_menuSprite.parent != null)
         {
            this.m_menuSprite.parent.removeChild(this.m_menuSprite);
         }
         if(this.m_menuSprite)
         {
            while(this.m_menuSprite.numChildren > 0)
            {
               itemSprite = this.m_menuSprite.getChildAt(0) as Sprite;
               if(itemSprite)
               {
                  itemSprite.removeEventListener(MouseEvent.CLICK,this.onMenuItemClick);
                  itemSprite.removeEventListener(MouseEvent.ROLL_OVER,this.onMenuItemRollOver);
                  itemSprite.removeEventListener(MouseEvent.ROLL_OUT,this.onMenuItemRollOut);
               }
               this.m_menuSprite.removeChildAt(0);
            }
         }
         this.killHideMenuTimer();
         Global.stage.removeEventListener(MouseEvent.CLICK,this.onStageClick);
      }
      
      override public function untoggle() : void
      {
         super.untoggle();
         if(!this.m_displayMenuOnRollover || this.m_displayMenuOnRollover && this.isMenuShown())
         {
            this.hideMenu();
         }
      }
      
      protected function onTimer(event:TimerEvent) : void
      {
         this.hideMenu();
      }
      
      protected function timedHideMenu() : void
      {
         if(this.m_timer == null)
         {
            this.m_timer = new Timer(CLOSE_MENU_DELAY);
            this.m_timer.addEventListener(TimerEvent.TIMER,this.onTimer,false,0,true);
            this.m_timer.start();
         }
      }
      
      protected function killHideMenuTimer() : void
      {
         if(this.m_timer != null)
         {
            this.m_timer.stop();
            this.m_timer = null;
         }
      }
      
      public function isMenuShown() : Boolean
      {
         return this.m_menuSprite.parent != null;
      }
      
      protected function drawBg() : void
      {
         var totalRows:int = this.getTotalItemRows();
         var totalCols:int = this.getTotalItemCols();
         if(totalRows > MAX_ROWS || totalCols > MAX_COLUMNS)
         {
            GlobalEngine.error("ActionMultiButton","Action menu buttons support a maximum of " + MAX_ROWS + " rows and " + MAX_COLUMNS + " columns of icons.");
            totalRows = Math.min(totalRows,MAX_ROWS);
            totalCols = Math.min(totalCols,MAX_COLUMNS);
         }
         this.m_background = new EmbeddedArt["multi_contextual_background_" + totalRows + "h" + totalCols + "w"]();
         this.m_background.x = 0;
         this.m_background.y = 0;
         var stagePos:Rectangle = this.getRect(Global.stage);
         var arrowOffset:Number = 0;
         if(m_arrowlessHeight > 0)
         {
            arrowOffset = m_arrowlessHeight - this.height;
         }
         this.m_menuSprite.x = stagePos.x;
         this.m_menuSprite.x += this.width - this.m_background.width >> 1;
         this.m_menuSprite.y = stagePos.y - this.m_background.height - arrowOffset + MENU_OFFSET;
         this.m_menuSprite.addChild(this.m_background);
      }
      
      private function getTotalItems() : int
      {
         var row:Array = null;
         var result:int = 0;
         for each(row in this.m_items)
         {
            result += row.length;
         }
         return result;
      }
      
      private function getTotalItemRows() : int
      {
         return this.m_items.length;
      }
      
      private function getTotalItemCols() : int
      {
         var maxNumCols:int = 0;
         var numRows:int = int(this.m_items.length);
         for(var row:int = 0; row < numRows; row++)
         {
            if(this.m_items[row].length > maxNumCols)
            {
               maxNumCols = int(this.m_items[row].length);
            }
         }
         return maxNumCols;
      }
   }
}

