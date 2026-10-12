package Classes
{
   import Classes.Constants.Experiments;
   import Classes.Constants.WorldsConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.ContextMenuItem;
   import Managers.FarmStatsManager;
   import Managers.XMASInnovationManager;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class XMASInnovationDeco extends DecoAvatarAction
   {
      
      protected static const INTERACT_OBJECT:String = "interactObject";
      
      protected static const LOOK_INSIDE:String = "look inside";
      
      protected static var ARROW_SCALE:Number = 0.5;
      
      protected static var m_arrowBitmaps:Object = new Object();
      
      private static const BASIC_ARROW_BITMAP_KEY:String = "BASIC_ARROW_BITMAP_KEY";
      
      public static const GUITAR_PICK:Class = EmbeddedArt.guitarPick;
      
      private var m_decoItem:FarmItem;
      
      protected var m_arrowArt:Class;
      
      protected var m_arrow:DisplayObject;
      
      private var isArrowAttached:Boolean;
      
      private var m_loadComplete:Boolean;
      
      public function XMASInnovationDeco(itemName:String = null)
      {
         super(itemName);
         this.isArrowAttached = false;
         this.m_loadComplete = false;
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_XMAS_INNOVATION) == Experiments.VARIANT_XMAS_INNOVATION)
         {
            this.attachArrowConditionallyAfterDelay();
         }
      }
      
      public function attachArrowConditionallyAfterDelay() : void
      {
         var timer:Timer = new Timer(10000,1);
         timer.addEventListener(TimerEvent.TIMER,this.loadCompleteEvent);
         timer.start();
      }
      
      public function loadCompleteEvent(e:Event = null) : void
      {
         this.m_loadComplete = true;
      }
      
      override public function onUpdate(delta:Number) : void
      {
         super.onUpdate(delta);
         if(this.m_loadComplete)
         {
            this.attachArrowConditionally();
         }
      }
      
      public function attachArrowConditionally(e:Event = null) : void
      {
         if(m_displayObject)
         {
            if(Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_XMAS)
            {
               this.m_decoItem = this.getItem();
               if(XMASInnovationManager.getInstance().IsBuildingReadyToHarvest(XMASInnovationManager.BUILDING_SLOT_MAP[this.m_decoItem.name]))
               {
                  this.m_arrowArt = GUITAR_PICK;
                  this.showArrowDisplay();
               }
               else
               {
                  this.hideArrowDisplay();
               }
            }
         }
      }
      
      override public function showMenu() : void
      {
         m_menuItems = this.getMenuItems();
         super.showMenu();
      }
      
      override protected function getMenuItems() : Array
      {
         var item:FarmItem = this.getItem();
         var menuItems:Array = new Array();
         if(item)
         {
            menuItems.push({
               "label":"Interact",
               "action":INTERACT_OBJECT
            });
         }
         if(item.allowMove)
         {
            menuItems.push({
               "label":ZLocUtils.t("FarmGame","Move"),
               "action":MOVE_OBJECT
            });
         }
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_XMAS_INNOVATION) == Experiments.VARIANT_XMAS_INNOVATION)
         {
            if(XMASInnovationManager.getInstance().isFeatureEnabled())
            {
               menuItems.push({
                  "label":ZLocUtils.t("FarmGame","LookInside"),
                  "action":LOOK_INSIDE
               });
            }
         }
         return menuItems;
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            switch(item.action)
            {
               case INTERACT_OBJECT:
                  if(!isAvatarPlaying())
                  {
                     this.activate();
                     FarmStatsManager.count("Interactive_Deco",m_originalItemName,"Interact");
                  }
                  break;
               case LOOK_INSIDE:
                  FarmStatsManager.count(XMASInnovationManager.FEATURE_OPTIONS_KEY,m_originalItemName,"look_inside","click");
                  XMASInnovationManager.getInstance().showMainUI();
                  break;
               default:
                  super.onMenuClick(event);
            }
         }
      }
      
      protected function setArrowPosition() : void
      {
         var spr:Sprite = null;
         if(Boolean(this.m_arrow) && Boolean(m_displayObject))
         {
            spr = m_displayObject as Sprite;
            this.m_arrow.scaleX = ARROW_SCALE / m_displayObject.scaleX;
            this.m_arrow.scaleY = ARROW_SCALE / m_displayObject.scaleY;
            if(spr.getChildAt(0))
            {
               this.m_arrow.y = -50;
               this.m_arrow.x = 200;
            }
         }
      }
      
      public function showArrowDisplay() : void
      {
         if(this.m_arrow == null)
         {
            this.m_arrow = this.generateHarvestArrow();
         }
         this.m_arrow.visible = true;
         if(this.m_arrow)
         {
            if(!this.isArrowAttached)
            {
               (m_displayObject as Sprite).addChild(this.m_arrow);
               this.isArrowAttached = true;
            }
            this.setArrowPosition();
         }
      }
      
      public function hideArrowDisplay() : void
      {
         if(this.m_arrow)
         {
            this.m_arrow.visible = false;
         }
      }
      
      protected function generateHarvestArrow() : DisplayObject
      {
         var arrow:DisplayObject = this.createHarvestArrow();
         this.setArrowBitmapsData(arrow);
         return arrow;
      }
      
      protected function createHarvestArrow() : DisplayObject
      {
         return new this.m_arrowArt();
      }
      
      protected function setArrowBitmapsData(arrow:DisplayObject) : void
      {
         if(m_arrowBitmaps[BASIC_ARROW_BITMAP_KEY] == null)
         {
            m_arrowBitmaps[BASIC_ARROW_BITMAP_KEY] = new BitmapData(arrow.width,arrow.height,true,0);
            m_arrowBitmaps[BASIC_ARROW_BITMAP_KEY].draw(arrow);
         }
      }
   }
}

