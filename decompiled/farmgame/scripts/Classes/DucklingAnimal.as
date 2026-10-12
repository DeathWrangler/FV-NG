package Classes
{
   import Classes.Constants.MFSConstants;
   import Display.ContextMenuItem;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import GameMode.GMDucklingAnimalPlace;
   import Managers.FarmStatsManager;
   import Managers.MFSRequestManager;
   import Transactions.TSetFriendSetProgress;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.filters.ColorMatrixFilter;
   import flash.geom.Point;
   
   public class DucklingAnimal extends Animal
   {
      
      public static const DUCKLING_GAME_FRIEND_SET_CODE:String = "FS02";
      
      private const DUCKLING_GAME:String = "DucklingGame";
      
      private const ASK_FOR_HELP:String = "AskForHelp";
      
      protected var m_madeProgressClass:Class;
      
      protected var m_madeProgressArrow:DisplayObject;
      
      protected var m_ducklingGameId:Number = 0;
      
      protected var m_madeProgress:Boolean = false;
      
      protected var m_attemptedProgress:Boolean = false;
      
      protected var m_gameComplete:Boolean = false;
      
      protected var m_currentColorTint:ColorMatrixFilter = null;
      
      protected var m_transformEnabled:Boolean = true;
      
      public function DucklingAnimal(animalType:String = null)
      {
         super(animalType);
         this.m_madeProgressClass = GOLD_ARROW;
      }
      
      override public function loadObject(data:Object) : void
      {
         super.loadObject(data);
         this.m_ducklingGameId = data.ducklingGameId;
         this.m_madeProgress = data.madeProgress;
         this.m_gameComplete = data.gameComplete;
         this.m_attemptedProgress = Boolean(data.hadHelp) || Boolean(data.madeProgress) || Boolean(data.gameComplete);
         this.m_transformEnabled = data.transformEnabled;
         if(!this.m_transformEnabled)
         {
            this.m_attemptedProgress = false;
            m_showExtraMenuItems = false;
         }
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            if(item.action == MOVE_OBJECT)
            {
               Global.world.addGameMode(new GMDucklingAnimalPlace(this),false);
            }
            else
            {
               super.onMenuClick(event);
            }
            if(this.m_transformEnabled)
            {
               switch(item.action)
               {
                  case this.DUCKLING_GAME:
                     UI.displayDuckGameWindow(this.ducklingGameId,this.getId(),this.getItemName());
                     FarmStatsManager.count("duck_pond_feature","duckling_context_menu","duckling_game");
                     break;
                  case this.ASK_FOR_HELP:
                     this.attemptedProgress();
                     MFSRequestManager.getInstance().makeFriendSetRequest(this.getItemName(),this.DUCKLING_GAME,DUCKLING_GAME_FRIEND_SET_CODE,this.ducklingGameId,MFSConstants.SOURCE_CONTEXT_MENU,"duck_pond_feature","duckling_context_menu","ask_for_help");
               }
            }
         }
      }
      
      public function keepForever() : void
      {
         this.m_transformEnabled = false;
         this.m_madeProgress = false;
         this.m_gameComplete = false;
         this.m_attemptedProgress = false;
         m_showExtraMenuItems = false;
         this.hideProgressDisplay();
      }
      
      public function get transformEnabled() : Boolean
      {
         return this.m_transformEnabled;
      }
      
      override public function drawDisplayObject() : void
      {
         super.drawDisplayObject();
         if((this.m_madeProgress || this.m_gameComplete) && !m_hideArrow && !Global.worldManager.isVisiting())
         {
            this.showProgressArrowDisplay();
         }
      }
      
      override public function onClick() : void
      {
         if((this.m_madeProgress || this.m_gameComplete) && !Global.worldManager.isVisiting())
         {
            TransactionManager.addTransaction(new TSetFriendSetProgress("FS02",this.ducklingGameId),false);
            this.m_gameComplete = false;
            this.m_madeProgress = false;
            this.hideProgressDisplay();
            UI.displayDuckGameWindow(this.ducklingGameId,this.getId(),this.getItemName());
         }
         else
         {
            super.onClick();
         }
      }
      
      public function get ducklingGameId() : Number
      {
         return this.m_ducklingGameId;
      }
      
      public function set ducklingGameId(value:Number) : void
      {
         this.m_ducklingGameId = value;
      }
      
      public function hasAnyProgress() : Boolean
      {
         return this.m_attemptedProgress || this.m_madeProgress || this.m_gameComplete;
      }
      
      public function attemptedProgress() : void
      {
         this.m_attemptedProgress = true;
      }
      
      public function showProgressArrowDisplay() : void
      {
         var spr:Sprite = null;
         this.m_hideArrow = false;
         if(this.m_madeProgressArrow == null)
         {
            this.m_madeProgressArrow = this.generateProgressArrow();
         }
         this.m_madeProgressArrow.visible = true;
         if(Boolean(this.m_madeProgressArrow) && !m_hideArrow)
         {
            spr = m_displayObject as Sprite;
            spr.addChild(this.m_madeProgressArrow);
            this.setProgressArrowPosition();
         }
      }
      
      protected function generateProgressArrow() : DisplayObject
      {
         var arrow:DisplayObject = new this.m_madeProgressClass();
         if(m_arrowBitmaps[this.m_madeProgressClass] == null)
         {
            m_arrowBitmaps[this.m_madeProgressClass] = new BitmapData(arrow.width,arrow.height,true,0);
            m_arrowBitmaps[this.m_madeProgressClass].draw(arrow);
         }
         return arrow;
      }
      
      protected function getProgressArrowBitmap() : BitmapData
      {
         return m_arrowBitmaps[this.m_madeProgressClass];
      }
      
      protected function setProgressArrowPosition() : void
      {
         var point:Point = null;
         var spr:Sprite = null;
         if(Boolean(this.m_madeProgressArrow) && Boolean(m_displayObject))
         {
            point = new Point();
            spr = m_displayObject as Sprite;
            this.m_madeProgressArrow.scaleX = ARROW_SCALE / m_displayObject.scaleX;
            this.m_madeProgressArrow.scaleY = ARROW_SCALE / m_displayObject.scaleY;
            if(spr.getChildAt(0))
            {
               point.y = -1 * Math.min(this.m_madeProgressArrow.height,DEFAULT_ARROW_SIZE_Y);
               point.x = (spr.getChildAt(0).width - Math.min(this.m_madeProgressArrow.width,DEFAULT_ARROW_SIZE_X) * spr.scaleX) / 2;
               if(point.x != this.m_madeProgressArrow.x || point.y != this.m_madeProgressArrow.y)
               {
                  this.m_madeProgressArrow.y = point.y - 30;
                  this.m_madeProgressArrow.x = point.x - 8;
               }
            }
         }
      }
      
      public function hideProgressDisplay() : void
      {
         if(Boolean(this.m_madeProgressArrow) && Boolean(this.m_madeProgressArrow.visible) && this.m_madeProgressArrow.parent != null)
         {
            this.m_madeProgressArrow.visible = false;
            this.m_hideArrow = true;
            this.m_madeProgressArrow.parent.removeChild(this.m_madeProgressArrow);
            this.m_madeProgressArrow = null;
            m_arrowBitmaps[this.m_madeProgressClass] = null;
            this.m_currentColorTint = null;
            this.conditionallyRedraw(true);
         }
      }
      
      override public function onSell() : void
      {
         var ducklingObj:DucklingAnimal = null;
         super.onSell();
         var ducklingObjs:Array = Global.world.getObjectsByClass(DucklingAnimal);
         for each(ducklingObj in ducklingObjs)
         {
            if(ducklingObj.ducklingGameId > this.ducklingGameId)
            {
               --ducklingObj.ducklingGameId;
            }
         }
      }
   }
}

