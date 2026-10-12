package Classes
{
   import Classes.storage.PartItem;
   import Classes.util.ZLocUtils;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Transactions.TTransformBuilding;
   import Widgets.Constants.Market.Currency;
   import Widgets.Windows.ConstructionBuilding.ConstructionBuildingSinglePartWindow;
   
   public class CombineChassisConstructionBuilding extends ConstructionBuilding
   {
      
      private static const COMBINE_CHASSIS_PROGRESS_ICON:String = "assets/newsfeed/garageparts_icon.png";
      
      private static const FEATURE_NAME:String = "Combine";
      
      private var m_part:PartItem = null;
      
      public function CombineChassisConstructionBuilding(buildingType:String = null)
      {
         super(buildingType);
      }
      
      override protected function onIncrementFinished(result:Object) : void
      {
         var part:PartItem = null;
         var numParts:int = 0;
         var itemFriendlyName:String = null;
         var iconURL:String = null;
         var bundleData:Object = null;
         var message:GenericIconPopup = null;
         if(result.rewardLink)
         {
            part = getConstructionItems().shift();
            numParts = part.onHand;
            itemFriendlyName = getItem().friendlyName;
            iconURL = Global.getAssetURL(COMBINE_CHASSIS_PROGRESS_ICON);
            bundleData = {
               "reward_link":result.rewardLink,
               "partCount":numParts,
               "itemName":itemFriendlyName,
               "images":[{
                  "href":"{SN_APP_URL}" + result.rewardLink,
                  "src":iconURL
               }]
            };
            message = new GenericIconPopup(ZLocUtils.t("Dialogs","CombineChassisProgress"),GenericPopup.TYPE_SHARE,generateOnConfirmShareFeed("CombineChassisProgress",bundleData,"","",getItem().name),getItem().icon);
            message.setTrackerKey("feed-share_combinechassis_incremental");
            UI.displayPopup(message);
         }
      }
      
      override public function displayStorageDialog(defaultAction:String = "") : void
      {
         if(defaultAction != ConstructionBuilding.MENU_COMPLETE_NOW)
         {
            UI.displayPopup(new ConstructionBuildingSinglePartWindow(this,FEATURE_NAME));
         }
         else
         {
            this.onBuyParts();
         }
      }
      
      private function onBuyParts() : void
      {
         var part:PartItem = null;
         var completionCost:int = 0;
         var buildingName:String = null;
         var buildingParts:Array = this.getConstructionItems();
         for each(part in buildingParts)
         {
            if(part.onHand < part.qtyNeeded)
            {
               this.m_part = part;
               break;
            }
         }
         completionCost = this.calculateCompletionCost();
         buildingName = this.getItemFriendlyName();
         FarmStatsManager.count("ui_button_click",FEATURE_NAME,"complete_now");
         UI.displayMessage(ZLocUtils.t("Dialogs","FinishConstructionBuildingPopup",{
            "cashQuantity":completionCost,
            "item":ZLocUtils.tk_pk(buildingName)
         }),GenericPopup.TYPE_ACCEPTCANCEL,this.onAcceptBuy,"",true);
      }
      
      private function onAcceptBuy(event:GenericPopupEvent) : void
      {
         var newItem:MapResource = null;
         var discount:int = 0;
         if(event.button == GenericPopup.YES)
         {
            if(Global.player.canBuyCash(this.calculateCompletionCost()))
            {
               newItem = this.transformBuilding() as MapResource;
               if(newItem)
               {
                  discount = newItem.getItem().cash - this.calculateCompletionCost();
                  Global.player.tryBuy(newItem,false,newItem.getItem(),discount,"",Currency.CASH);
                  TransactionManager.addTransaction(new TTransformBuilding(this));
               }
            }
         }
      }
      
      private function calculateCompletionCost() : int
      {
         return int((this.m_part.qtyNeeded - this.m_part.onHand) * this.m_part.item.cash);
      }
   }
}

