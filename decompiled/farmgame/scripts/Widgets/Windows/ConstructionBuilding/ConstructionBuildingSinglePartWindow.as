package Widgets.Windows.ConstructionBuilding
{
   import Classes.Constants.MFSConstants;
   import Classes.ConstructionBuilding;
   import Classes.MapResource;
   import Classes.storage.PartItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Managers.MFSRequestManager;
   import Transactions.TTransformBuilding;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Constants.Market.Currency;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   
   public class ConstructionBuildingSinglePartWindow extends FarmWindow
   {
      
      private const DIALOG_ASSET:String = "assets/dialogs/FV_Combine_Incomplete.swf";
      
      private const BUTTON_CLICK_STATS_COUNTER:String = "ui_button_click";
      
      private const ICON_SIZE:Number = 50;
      
      private var m_featureName:String = "";
      
      private var m_building:ConstructionBuilding = null;
      
      private var m_part:PartItem = null;
      
      public function ConstructionBuildingSinglePartWindow(constructionBuilding:ConstructionBuilding, featureName:String, modal:Boolean = true, bAddClickBlocker:Boolean = false)
      {
         var part:PartItem = null;
         FarmStatsManager.sample(1000,"fv_fbml_depr_inspect","ConstructionBuildingSinglePartWindow","called");
         super(this.DIALOG_ASSET,modal,bAddClickBlocker);
         this.m_building = constructionBuilding;
         this.m_featureName = featureName;
         var buildingParts:Array = this.m_building.getConstructionItems();
         for each(part in buildingParts)
         {
            if(part.onHand < part.qtyNeeded)
            {
               this.m_part = part;
               break;
            }
         }
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         var buildingIcon:FarmIcon = new FarmIcon(m_window.topIcon_mc,this.m_building.getBuildingIcon());
         addWidget(buildingIcon);
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.tk_pk_asTitle(this.m_building.getItemFriendlyName())));
         addWidget(new ZwTextField(m_window.generic_tf,ZLocUtils.t("Dialogs",this.m_building.getItem().name + "_bodyText")));
         var card:ZwFrame = new ZwFrame(m_window.giftPanel0);
         card.addWidget(new ZwTextField(m_window.giftPanel0.itemTitle_tf,ZLocUtils.tk_pk_asTitle(this.m_part.item.friendlyName)));
         var itemIcon:FarmIcon = new FarmIcon(m_window.giftPanel0.icon_mc,this.m_part.item.icon);
         itemIcon.setIconSize(this.ICON_SIZE,this.ICON_SIZE);
         card.addWidget(itemIcon);
         card.addWidget(new ZwTextField(m_window.giftPanel0.alive_tf,ZLocUtils.t("Dialogs","ConstructionBuildingMatCount",{
            "quantity":this.m_part.onHand,
            "maximum":this.m_part.qtyNeeded
         })));
         addWidget(card);
         addWidget(new FarmAnimatedTextButton(m_window.ask_bt,ZLocUtils.t("Dialogs","AskForMore"),this.onAskParts));
         addWidget(new FarmAnimatedTextButton(m_window.buy_bt,ZLocUtils.t("Dialogs","CompleteNow"),this.onBuy));
      }
      
      override protected function release() : void
      {
         this.m_building = null;
         this.m_part = null;
         super.release();
      }
      
      private function onAskParts(event:Event) : void
      {
         FarmStatsManager.sample(100,"fv_fbml_depr_inspect","r2FlowCalled","ConstructionBuildingSinglePartWindow");
         MFSRequestManager.getInstance().makeAskMatsRequest(this.m_featureName,this.m_part.item.name,"","",MFSConstants.SOURCE_DIALOG_CLICKED,this.BUTTON_CLICK_STATS_COUNTER,this.m_featureName,"ask_for_more");
      }
      
      private function onBuy(event:Event) : void
      {
         var completionCost:int = this.calculateCompletionCost();
         var buildingName:String = this.m_building.getItemFriendlyName();
         FarmStatsManager.count(this.BUTTON_CLICK_STATS_COUNTER,this.m_featureName,"complete_now");
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
               newItem = this.m_building.transformBuilding() as MapResource;
               if(newItem)
               {
                  discount = newItem.getItem().cash - this.calculateCompletionCost();
                  Global.player.tryBuy(newItem,false,newItem.getItem(),discount,"",Currency.CASH);
                  TransactionManager.addTransaction(new TTransformBuilding(this.m_building));
               }
            }
         }
         onClose(event);
      }
      
      private function calculateCompletionCost() : int
      {
         return int((this.m_part.qtyNeeded - this.m_part.onHand) * this.m_part.item.cash);
      }
   }
}

