package Classes
{
   import Classes.util.ZLocUtils;
   import Display.ContextMenuItem;
   import Display.InventoryCellarDialog;
   import Display.UI;
   import Widgets.Windows.ArrowIndicatorWindow;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   
   public class InventoryCellar extends RewardCreditsBuilding
   {
      
      public static const DIALOG_SIDE_ICON:String = "assets/decorations/deco_shovel_icon.png";
      
      public static const ASK_FOR_CREDITS_FEATURE_NAME:String = "InventoryCellar";
      
      private const INTERVAL_FEED_ICON:String = "assets/decorations/deco_shovel_icon.png";
      
      private const LOCALE_PREFIX:String = "InventoryCellar_";
      
      private const BUNDLE_PREFIX:String = "InventoryCellar";
      
      private const NEIGHBOR_PASS_FEED_FLAG_NAME:String = "cellarPass";
      
      public var m_cellarArrowIndicator:ArrowIndicatorWindow;
      
      private var m_shouldHide:Boolean = false;
      
      private var m_arrowIndicatorCurrentlyHidden:Boolean = true;
      
      private const URL_INDICATOR_ICON:String = "assets/decorations/deco_shovel_icon.png";
      
      private const PT_INDICATOR_ARROW_OFFSET:Point = new Point(0,-100);
      
      public function InventoryCellar(buildingType:String = null)
      {
         super(buildingType,"InventoryCellar");
      }
      
      public static function isInCellarExperiment() : Boolean
      {
         return true;
      }
      
      override public function displayStorageDialog(defaultAction:String = "") : void
      {
         if(!Global.player.getSeenFlag("cellarOpen"))
         {
            Global.player.setSeenFlag("cellarOpen");
            UI.displayStorageDialog(new InventoryCellarDialog(this,true));
         }
         else
         {
            UI.displayStorageDialog(new InventoryCellarDialog(this,false));
         }
      }
      
      override public function onBuildComplete(result:Object) : void
      {
         super.onBuildComplete(result);
         this.displayStorageDialog();
      }
      
      override public function getLocKeyPrefix() : String
      {
         return this.LOCALE_PREFIX;
      }
      
      override public function getBundlePrefix() : String
      {
         return this.BUNDLE_PREFIX;
      }
      
      override public function getDialogSideIconUrl() : String
      {
         return DIALOG_SIDE_ICON;
      }
      
      override public function getLevelIconUrl() : String
      {
         return "assets/newsfeed/undergroundstorage_" + getCurrentSuffix() + ".png";
      }
      
      override public function getIntervalFeedIconUrl() : String
      {
         return this.INTERVAL_FEED_ICON;
      }
      
      override protected function getNeighborPassFeedFlagName() : String
      {
         return this.NEIGHBOR_PASS_FEED_FLAG_NAME;
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            switch(item.action)
            {
               case REMOVEFROM_OBJECT:
                  this.displayStorageDialog();
                  this.removeArrowIndicator();
                  break;
               default:
                  super.onMenuClick(event);
            }
         }
      }
      
      override public function get capacity() : Number
      {
         return Math.min(super.capacity,getTotalCreditsReceived());
      }
      
      override public function isClearable() : Boolean
      {
         return false;
      }
      
      override protected function getOwnerToolTipText() : String
      {
         var used:int = Global.player.getInventoryUsage();
         var total:int = Global.player.getInventoryCapacity();
         var depthText:String = ZLocUtils.t("Items","hatchstorage_depth",{"quantity":this.capacity});
         var usageText:String = ZLocUtils.t("Items","hatchstorage_usage",{
            "quantity":used,
            "maximum":total
         });
         return depthText + "\n" + usageText;
      }
      
      override protected function hasStartFeed() : Boolean
      {
         return true;
      }
      
      override public function setPosition(newX:Number, newY:Number, newZ:Number = 0) : void
      {
         super.setPosition(newX,newY,newZ);
         this.setArrowPosition();
      }
      
      override protected function setArrowPosition() : void
      {
         var point:Point = null;
         var spr:Sprite = null;
         if(Boolean(this.m_cellarArrowIndicator) && Boolean(m_displayObject))
         {
            point = new Point();
            spr = m_displayObject as Sprite;
            if(spr.getChildAt(0))
            {
               point.y = this.PT_INDICATOR_ARROW_OFFSET.y;
               point.x = this.PT_INDICATOR_ARROW_OFFSET.x;
               if(point.x != this.m_cellarArrowIndicator.x || point.y != this.m_cellarArrowIndicator.y)
               {
                  this.m_cellarArrowIndicator.y = point.y;
                  this.m_cellarArrowIndicator.x = point.x;
               }
            }
         }
      }
      
      private function createArrowIndicator() : ArrowIndicatorWindow
      {
         var arrowIndicator:ArrowIndicatorWindow = null;
         var title:String = ZLocUtils.t("Dialogs","InventoryCellar_StorageIncrease_Title");
         var text:String = ZLocUtils.t("Dialogs","InventoryCellar_StorageIncrease_Text");
         return new ArrowIndicatorWindow(this.URL_INDICATOR_ICON,title,text);
      }
      
      public function removeArrowIndicator() : void
      {
         if(Boolean(this.m_cellarArrowIndicator) && Boolean(this.m_cellarArrowIndicator.visible) && this.m_cellarArrowIndicator.parent != null)
         {
            this.m_cellarArrowIndicator.visible = false;
            this.m_cellarArrowIndicator.parent.removeChild(this.m_cellarArrowIndicator);
            this.m_cellarArrowIndicator = null;
            conditionallyRedraw(true);
            this.m_arrowIndicatorCurrentlyHidden = true;
         }
      }
      
      private function updateArrowIndicator(showText:Boolean) : void
      {
         if(this.m_cellarArrowIndicator)
         {
            this.m_cellarArrowIndicator.showRolloverText(showText);
         }
      }
   }
}

