package GameMode
{
   import Classes.MapResource;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Classes.WorldObject;
   import Engine.Constants;
   import Engine.Managers.LoadingManager;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.AltGraphicUtility;
   import Transactions.TSetOverlay;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   
   public class GMSetAltGraphic extends GMDefault
   {
      
      private const DYNAMIC_CURSOR_ASSET:String = "assets/cursors/counterCursor.swf";
      
      private var m_highlightedPoint:Point;
      
      private var m_object:WorldObject;
      
      private var m_cost:int = 0;
      
      protected var m_graphic:String;
      
      protected var m_selectableObjects:int = 0;
      
      protected var m_glowColor:int = 15534960;
      
      protected var m_selectedToolTipLocalizeKey:String;
      
      protected var m_cursorIcon:DisplayObject;
      
      public function GMSetAltGraphic(graphicName:String)
      {
         super();
         var graphicKey:String = AltGraphicUtility.getAltGraphicCreditKey(graphicName);
         this.m_graphic = graphicKey;
         var gameSettings:XML = Global.farmGameSettingsManager.getAltGraphicByName(this.m_graphic);
         if(gameSettings)
         {
            this.m_glowColor = gameSettings.highlight;
            this.m_cost = gameSettings.cash;
            LoadingManager.load(Global.getAssetURL((gameSettings.cursor as XMLList).toString()),this.setCursorIcon);
            LoadingManager.load(Global.getAssetURL(this.DYNAMIC_CURSOR_ASSET),this.setCursorImage);
         }
         this.m_selectedToolTipLocalizeKey = "ClickTo" + this.m_graphic;
      }
      
      override public function onMouseMove(event:MouseEvent) : Boolean
      {
         super.onMouseMove(event);
         if(m_highlightedObject != null)
         {
            if(m_dragging)
            {
               this.deselectObject();
            }
         }
         return true;
      }
      
      protected function setCursorIcon(e:Event) : void
      {
         this.m_cursorIcon = e.target.content;
         if(m_cursorImage != null)
         {
            m_cursorImage.cursor_mc.addChildAt(this.m_cursorIcon,m_cursorImage.cursor_mc.numChildren);
            m_cursorImage.cursor_mc.swapChildrenAt(0,1);
         }
      }
      
      public function updateCursorText(text:String) : void
      {
         if(m_cursorImage)
         {
            m_cursorImage.cursor_mc.generic_tf.text = text;
         }
      }
      
      protected function setCursorImage(e:Event) : void
      {
         m_cursorImage = e.target.content;
         (m_cursorImage.cursor_mc.generic_tf as TextField).autoSize = TextFieldAutoSize.LEFT;
         if(Global.player.hasUnlimitedCredits(this.m_graphic))
         {
            m_cursorImage.cursor_mc.generic_tf.text = "";
         }
         else if(Global.player.numAltGraphicCredits(this.m_graphic) == 0)
         {
            ZLocUtils.setText(m_cursorImage,"cursor_mc.generic_tf","FarmGame","AltGraphicCostCursor",{"quantity":this.m_cost});
         }
         else if(Global.player.numAltGraphicCredits(this.m_graphic) < 10)
         {
            ZLocUtils.setText(m_cursorImage,"cursor_mc.generic_tf","FarmGame","AltGraphicRemainingCursorFew",{"quantity":Global.player.numAltGraphicCredits(this.m_graphic)});
         }
         else
         {
            ZLocUtils.setText(m_cursorImage,"cursor_mc.generic_tf","FarmGame","AltGraphicRemainingCursor",{"quantity":Global.player.numAltGraphicCredits(this.m_graphic)});
         }
         if(this.m_cursorIcon != null)
         {
            m_cursorImage.cursor_mc.addChildAt(this.m_cursorIcon,1);
         }
         var idx:int = int(m_cursorImage.cursor_mc.getChildIndex(m_cursorImage.cursor_mc.generic_tf));
         m_cursorImage.cursor_mc.swapChildrenAt(0,1);
      }
      
      protected function lastAltGraphicRoutine() : void
      {
         var dialog:GenericPopup;
         var dialogCallback:Function = null;
         switch(this.m_graphic)
         {
            case "web":
               dialogCallback = function(event:GenericPopupEvent):void
               {
                  if(event.button == GenericPopup.ACCEPT)
                  {
                     UI.displayMarketDialog("OutOfAltGraphic_web","decoration");
                  }
               };
         }
         dialog = new GenericPopup(ZLocUtils.t("Dialogs","LastAltGraphic_" + this.m_graphic),GenericPopup.TYPE_OK,dialogCallback,GenericPopup.GENERIC_ASSET,"",false,false,true);
         dialog.setAcceptTextName("Accept");
         UI.displayPopup(dialog,false);
      }
      
      override protected function handleClick(event:MouseEvent) : void
      {
         var object:MapResource = null;
         var popMode:Boolean = false;
         var paid:Boolean = false;
         var didit:Boolean = false;
         var gameSettings:XML = null;
         if(m_highlightedObject)
         {
            object = m_highlightedObject as MapResource;
            if(object)
            {
               if(this.isObjectSelectable(object))
               {
                  popMode = false;
                  paid = Global.player.numAltGraphicCredits(this.m_graphic) == 0 && !Global.player.hasUnlimitedCredits(this.m_graphic);
                  if(Global.player.numAltGraphicCredits(this.m_graphic) > 1)
                  {
                     if(Global.player.numAltGraphicCredits(this.m_graphic) < 10)
                     {
                        ZLocUtils.setText(m_cursorImage,"cursor_mc.generic_tf","FarmGame","AltGraphicRemainingCursorFew",{"quantity":Global.player.numAltGraphicCredits(this.m_graphic) - 1});
                     }
                     else
                     {
                        ZLocUtils.setText(m_cursorImage,"cursor_mc.generic_tf","FarmGame","AltGraphicRemainingCursor",{"quantity":Global.player.numAltGraphicCredits(this.m_graphic) - 1});
                     }
                  }
                  else if(Global.player.numAltGraphicCredits(this.m_graphic) == 1)
                  {
                     ZLocUtils.setText(m_cursorImage,"cursor_mc.generic_tf","FarmGame","AltGraphicCostCursor",{"quantity":this.m_cost});
                     popMode = true;
                     this.lastAltGraphicRoutine();
                  }
                  didit = false;
                  gameSettings = Global.farmGameSettingsManager.getAltGraphicByName(this.m_graphic);
                  if(Boolean(gameSettings.overlayName) && Boolean(gameSettings.overlayName != "") && object.isValidOverlayTarget(gameSettings.overlayName))
                  {
                     didit = true;
                     object.applyOverlay(gameSettings.overlayName);
                     TransactionManager.addTransaction(new TSetOverlay(object,this.m_graphic + "Overlay"));
                     if(Global.player.numAltGraphicCredits(this.m_graphic) > 0)
                     {
                        Global.player.decAltGraphicCredits(this.m_graphic);
                     }
                     else
                     {
                        Global.player.cash -= this.m_cost;
                     }
                  }
                  else
                  {
                     didit = object.setAltGraphic(this.m_graphic,this.m_cost);
                  }
                  if(didit && paid)
                  {
                     object.displayStatus(ZLocUtils.t("FarmGame","AltGraphicCost_" + this.m_graphic,{"quantity":this.m_cost}),"",null,1.5,32,32);
                  }
                  if(didit && popMode || !didit)
                  {
                     Global.world.removeGameMode(this);
                     Global.world.setDefaultGameMode();
                  }
               }
            }
            else
            {
               object.displayStatus(ZLocUtils.t("FarmGame","CannotApply_" + this.m_graphic));
            }
         }
      }
      
      override protected function selectObject(object:WorldObject, event:MouseEvent = null) : void
      {
         var farmObj:MapResource = object as MapResource;
         if(object != m_highlightedObject)
         {
            this.deselectObject();
            m_highlightedObject = object;
            if(object)
            {
               farmObj.getDisplayObject().filters = [new GlowFilter(Constants.COLOR_HIGHLIGHT,1,8,8,20)];
               farmObj.setToolTip(ZLocUtils.t("FarmGame",this.m_selectedToolTipLocalizeKey));
            }
            updateCursor();
         }
      }
      
      override protected function deselectObject() : void
      {
         var obj:WorldObject = m_highlightedObject;
         super.deselectObject();
         if(obj != null && this.isObjectSelectable(obj))
         {
            obj.getDisplayObject().filters = [new GlowFilter(this.m_glowColor,1,4,4,20)];
         }
      }
      
      override protected function getCursor() : Object
      {
         return m_cursorImage;
      }
      
      override protected function isObjectSelectable(object:WorldObject) : Boolean
      {
         var gameSettings:XML = null;
         var result:Boolean = false;
         var mapObject:MapResource = object as MapResource;
         if(mapObject != null)
         {
            gameSettings = Global.farmGameSettingsManager.getAltGraphicByName(this.m_graphic);
            if(mapObject.isAltGraphicAvailable(this.m_graphic))
            {
               if(mapObject.altGraphic == "")
               {
                  result = mapObject.canSetAltGraphic(this.m_graphic);
               }
            }
            else
            {
               result = mapObject.isValidOverlayTarget(gameSettings.overlayName);
            }
         }
         return result;
      }
      
      public function get numSelectableObjects() : int
      {
         return this.m_selectableObjects;
      }
      
      override public function enableMode() : void
      {
         var mapObject:MapResource = null;
         super.enableMode();
         var objects:Array = Global.world.getObjects();
         for(var objectIdx:int = 0; objectIdx < objects.length; objectIdx++)
         {
            mapObject = objects[objectIdx] as MapResource;
            if(mapObject != null && this.isObjectSelectable(mapObject))
            {
               ++this.m_selectableObjects;
               mapObject.getDisplayObject().filters = [new GlowFilter(this.m_glowColor,1,4,4,20)];
            }
         }
      }
      
      override public function disableMode() : void
      {
         var mapObject:MapResource = null;
         super.disableMode();
         var objects:Array = Global.world.getObjects();
         for(var objectIdx:int = 0; objectIdx < objects.length; objectIdx++)
         {
            mapObject = objects[objectIdx] as MapResource;
            if(mapObject != null && this.isObjectSelectable(mapObject))
            {
               mapObject.setHighlighted(false);
            }
         }
      }
   }
}

