package Classes
{
   import Classes.Quest.PrerequisiteUtility;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.ContextMenuItem;
   import Display.HUD.HUD;
   import Managers.OrderBoard.FarmersMarketInnovationManager;
   import Managers.TuscanyInnovationManager;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class FarmersMarketBonusRewardMapTrigger extends RotateableDecoration
   {
      
      protected static const HARVEST:String = "look inside";
      
      protected static var ARROW_SCALE:Number = 0.5;
      
      protected static var m_arrowBitmaps:Object = {};
      
      private static const BASIC_ARROW_BITMAP_KEY:String = "BASIC_ARROW_BITMAP_KEY";
      
      public static const GUITAR_PICK:Class = EmbeddedArt.guitarPick;
      
      public static const FEATURE_NAME:String = "FarmersMarket2020Innovation";
      
      protected var m_arrowArt:Class;
      
      protected var m_arrow:DisplayObject;
      
      private var isArrowAttached:Boolean;
      
      private var m_loadComplete:Boolean;
      
      public function FarmersMarketBonusRewardMapTrigger(itemName:String = null)
      {
         super(itemName);
         this.isArrowAttached = false;
         this.m_loadComplete = false;
         m_itemName = itemName;
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
         if(m_displayObject)
         {
            farmitem = this.getItem();
            if(FarmersMarketInnovationManager.getInstance().canHarvestBonusRewardBuilding() && FarmersMarketInnovationManager.getInstance().isDecosReadyForHarvest(m_itemName))
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
                  if(FarmersMarketInnovationManager.getInstance().canHarvestBonusRewardBuilding() && FarmersMarketInnovationManager.getInstance().shouldShowBonusHarvestTimer())
                  {
                     setOverrideToolTip(farmitem.friendlyTitle + "\n" + "Harvest in " + HUD.getformattedTimeLeft(FarmersMarketInnovationManager.getInstance().getTimeLeftForBonusHarvest(m_itemName)));
                  }
                  else
                  {
                     setOverrideToolTip(farmitem.friendlyTitle);
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
         var menuItems:Array = [];
         if(item.allowMove)
         {
            menuItems.push({
               "label":ZLocUtils.t("FarmGame","Move"),
               "action":MOVE_OBJECT
            });
         }
         if(FarmersMarketInnovationManager.getInstance().canHarvestBonusRewardBuilding() && FarmersMarketInnovationManager.getInstance().isDecosReadyForHarvest(m_itemName))
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
                  FarmersMarketInnovationManager.getInstance().harvestBonusBuilding(m_itemName);
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
               this.m_arrow.y = -15;
               this.m_arrow.x = 50;
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
         var result:Boolean = false;
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("tuscany_innovation_enabled");
         if(!PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            result = true;
         }
         return result;
      }
      
      public function updateState() : void
      {
         if(TuscanyInnovationManager.getInstance().isBoosterApplied())
         {
            state = "stars";
            this.setState(state);
         }
         else
         {
            state = "horizontal";
            this.setState(state);
         }
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

