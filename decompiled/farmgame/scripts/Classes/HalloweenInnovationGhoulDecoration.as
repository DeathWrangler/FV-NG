package Classes
{
   import Classes.Quest.PrerequisiteUtility;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.ContextMenuItem;
   import Managers.FarmStatsManager;
   import Managers.OrderBoard.HalloweenInnovationGhoulManager;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class HalloweenInnovationGhoulDecoration extends Decoration
   {
      
      protected static const HARVEST:String = "Harvest";
      
      protected static var ARROW_SCALE:Number = 0.5;
      
      protected static var m_arrowBitmaps:Object = new Object();
      
      private static const BASIC_ARROW_BITMAP_KEY:String = "BASIC_ARROW_BITMAP_KEY";
      
      private static const FEATURE_NAME:String = "HalloweenInnovationGhoul";
      
      public static const GUITAR_PICK:Class = EmbeddedArt.guitarPick;
      
      protected var m_arrowArt:Class;
      
      protected var m_arrow:DisplayObject;
      
      private var isArrowAttached:Boolean;
      
      private var m_loadComplete:Boolean;
      
      private var m_item_Name:String;
      
      public function HalloweenInnovationGhoulDecoration(itemName:String = null)
      {
         super(itemName);
         this.isArrowAttached = false;
         this.m_loadComplete = false;
         this.m_item_Name = itemName;
         this.attachArrowConditionallyAfterDelay();
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
         var farmitem:FarmItem = null;
         var prereq:Object = null;
         if(m_displayObject)
         {
            farmitem = this.getItem();
            if(HalloweenInnovationGhoulManager.getInstance(FEATURE_NAME).isDecosReadyForHarvest(this.m_item_Name))
            {
               this.m_arrowArt = GUITAR_PICK;
               this.showArrowDisplay();
               if(farmitem)
               {
                  setOverrideToolTip(farmitem.friendlyTitle + "\n" + "Harvest now");
               }
            }
            else
            {
               this.hideArrowDisplay();
               if(farmitem)
               {
                  prereq = Global.farmGameSettingsManager.getPrereqByName("HalloweenInnovationGhoul_innovation_harvest_enabled");
                  if(!PrerequisiteUtility.isPrerequisiteMet(prereq))
                  {
                     setOverrideToolTip(farmitem.friendlyTitle);
                  }
                  else if(HalloweenInnovationGhoulManager.getInstance(FEATURE_NAME).hasHarvestExpiryDatePassedForFeature(this.m_item_Name) == false)
                  {
                     setOverrideToolTip(farmitem.friendlyTitle + "\n" + "Harvest in " + HalloweenInnovationGhoulManager.getInstance(FEATURE_NAME).getHarvestTime(this.m_item_Name));
                  }
                  else
                  {
                     setOverrideToolTip(farmitem.friendlyTitle);
                  }
               }
            }
         }
      }
      
      private function get manager() : HalloweenInnovationGhoulManager
      {
         return HalloweenInnovationGhoulManager.getInstance("HalloweenInnovationGhoul");
      }
      
      override public function onClick() : void
      {
         if(Boolean(this.manager) && this.manager.isDecosReadyForHarvest(this.m_item_Name))
         {
            FarmStatsManager.count(FEATURE_NAME,m_originalItemName,"harvest","click");
            this.manager.harvestFinalDecos(this.m_item_Name);
         }
         else
         {
            this.showMenu();
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
         var menuItems:Array = [];
         if(item.allowMove)
         {
            menuItems.push({
               "label":ZLocUtils.t("FarmGame","Move"),
               "action":MOVE_OBJECT
            });
         }
         if(item.allowStore)
         {
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
               case HARVEST:
                  FarmStatsManager.count(FEATURE_NAME,m_originalItemName,"harvest","click");
                  HalloweenInnovationGhoulManager.getInstance(FEATURE_NAME).harvestFinalDecos(this.m_item_Name);
                  break;
               default:
                  super.onMenuClick(event);
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
      
      public function hideArrowDisplay() : void
      {
         if(this.m_arrow)
         {
            this.m_arrow.visible = false;
         }
      }
      
      override protected function canShowStoreMenuItem() : Boolean
      {
         var result:Boolean = false;
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("HalloweenInnovationGhoul_innovation_harvest_enabled");
         if(!PrerequisiteUtility.isPrerequisiteMet(prereq) || !HalloweenInnovationGhoulManager.getInstance(FEATURE_NAME).hasExpiryDatePassedForFeature())
         {
            result = true;
         }
         return result;
      }
   }
}

