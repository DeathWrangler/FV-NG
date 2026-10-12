package Classes
{
   import Classes.Quest.PrerequisiteUtility;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.ContextMenuItem;
   import Display.HUD.HUD;
   import Managers.GuildEventManager;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class GuildEventBonus extends RotateableDecoration
   {
      
      protected static const HARVEST:String = "look inside";
      
      protected static var ARROW_SCALE:Number = 0.5;
      
      protected static var m_arrowBitmaps:Object = new Object();
      
      private static const BASIC_ARROW_BITMAP_KEY:String = "BASIC_ARROW_BITMAP_KEY";
      
      public static const GUITAR_PICK:Class = EmbeddedArt.guitarPick;
      
      private static const coopXML:Class = GuildEventBonus_coopXML;
      
      public static const featureXML:XML = XML(new coopXML());
      
      protected var m_arrowArt:Class;
      
      protected var m_arrow:DisplayObject;
      
      private var isArrowAttached:Boolean;
      
      private var m_loadComplete:Boolean;
      
      public function GuildEventBonus(itemName:String = null)
      {
         super(itemName);
         this.isArrowAttached = false;
         this.m_loadComplete = false;
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
         this.updateState();
      }
      
      public function attachArrowConditionally(e:Event = null) : void
      {
         var farmitem:FarmItem = null;
         var prereq:Object = null;
         if(m_displayObject)
         {
            farmitem = this.getItem();
            if(GuildEventManager.getInstance().isBonusBuildingReadyToHarvest(this.buildingName))
            {
               this.m_arrowArt = GUITAR_PICK;
               this.showArrowDisplay();
               if(GuildEventManager.getInstance().isBonusHarvestExpired() == false)
               {
                  if(farmitem)
                  {
                     setOverrideToolTip(farmitem.friendlyTitle + "\n" + "Harvest now");
                  }
               }
            }
            else
            {
               this.hideArrowDisplay();
               if(farmitem)
               {
                  prereq = Global.farmGameSettingsManager.getPrereqByName(featureXML.child("guildEeventBonusEnabled"));
                  if(!PrerequisiteUtility.isPrerequisiteMet(prereq))
                  {
                     setOverrideToolTip(farmitem.friendlyTitle);
                  }
                  else if(GuildEventManager.getInstance().isBonusHarvestExpired() == false)
                  {
                     setOverrideToolTip(farmitem.friendlyTitle + "\n" + "Harvest in " + HUD.getformattedTimeLeft(GuildEventManager.getInstance().getTimeLeftForBonusHarvest(this.buildingName)));
                  }
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
         if(item.allowMove)
         {
            menuItems.push({
               "label":ZLocUtils.t("FarmGame","Move"),
               "action":MOVE_OBJECT
            });
         }
         if(GuildEventManager.getInstance().isBonusBuildingReadyToHarvest(this.buildingName))
         {
            menuItems.push({
               "label":ZLocUtils.t("FarmGame","Harvest"),
               "action":HARVEST
            });
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
                  GuildEventManager.getInstance().harvestBonusBuilding(this.buildingName);
                  break;
               default:
                  super.onMenuClick(event);
            }
         }
      }
      
      public function get buildingName() : String
      {
         var name:String = "";
         var farmitem:FarmItem = this.getItem();
         if(farmitem)
         {
            name = farmitem.name;
         }
         return name;
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
      
      override protected function canShowStoreMenuItem() : Boolean
      {
         return true;
      }
      
      public function updateState() : void
      {
         state = "horizontal";
         this.setState(state);
      }
      
      override public function getCurrentImageName() : String
      {
         return state;
      }
      
      override public function setState(value:String) : void
      {
         state = value;
         m_image = null;
         m_maskBitmapData = null;
         setDisplayObjectDirty(true);
         conditionallyRedraw();
      }
   }
}

