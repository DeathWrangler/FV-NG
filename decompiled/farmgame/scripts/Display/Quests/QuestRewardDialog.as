package Display.Quests
{
   import Classes.Avatar.AvatarItem;
   import Classes.Avatar.AvatarManager;
   import Classes.Constants.Experiments;
   import Classes.Quest.FarmQuestManager;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Events.TransactionEvent;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Transactions.Quests.TShareQuestLoot;
   import Transactions.TBuyAvatarItem;
   import Transactions.TBuyItemPutGiftbox;
   import Widgets.Constants.Market.Currency;
   import Widgets.Interfaces.IQuestRewardView;
   import com.troyer.widget.controller.BaseWidgetController;
   import com.troyer.widget.controller.ButtonController;
   import com.troyer.widget.controller.CellController;
   import com.troyer.widget.controller.ImageController;
   import com.troyer.widget.controller.ResizeController;
   import com.troyer.widget.event.WidgetControllerEvent;
   import com.troyer.widget.interfaces.ICellController;
   import com.troyer.widget.view.BaseWidgetView;
   import com.troyer.widget.view.TextFieldView;
   import flash.utils.Dictionary;
   
   public class QuestRewardDialog extends QuestDialog implements ICellController, IQuestRewardView
   {
      
      private static const URL_KEY:String = "url";
      
      private static const QUANTITY_KEY:String = "quantity";
      
      public static const PAYMENT_CONFIRMATION_MINIMUM:int = 10;
      
      protected var m_rewardList:Array = null;
      
      protected var m_purchaseData:Dictionary = new Dictionary();
      
      protected var m_buttonControllers:Array = new Array();
      
      private var m_currentItem:FarmItem = null;
      
      public function QuestRewardDialog(view:BaseWidgetView)
      {
         super(view);
      }
      
      public function onCellCreate(controllerName:String, index:int, newCell:BaseWidgetController) : BaseWidgetController
      {
         var controller:BaseWidgetController = null;
         controller = newCell.getChildController("rewardItem");
         if(controller != null)
         {
            controller.setAttribute(ImageController.ATTRIBUTE_SOURCE,this.m_rewardList[index][URL_KEY]);
         }
         controller = newCell.getChildController("quantityText");
         if(controller != null)
         {
            controller.setAttribute(TextFieldView.ATTRIBUTE_TEXT,this.m_rewardList[index][QUANTITY_KEY]);
         }
         var purchaseData:Object = m_questObject.getPurchaseDataAtIndex(index);
         if(Boolean(purchaseData && purchaseData.buyable && purchaseData.marketType == Currency.CASH) && Boolean(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_QUEST_REWARD_PURCHASE) > 1) && Global.player.hasGiftBoxCapacity())
         {
            controller = newCell.getChildController("farmCashCostText");
            if(controller != null)
            {
               controller.setAttribute(TextFieldView.ATTRIBUTE_TEXT,String(purchaseData.cost));
            }
            controller = newCell.getChildController("buyButton");
            if(controller != null)
            {
               this.m_purchaseData[index] = purchaseData;
               controller.listen(WidgetControllerEvent.BUTTON_PRESSED,this.onBuyButtonPressed);
               controller.index = index;
               this.m_buttonControllers.push(controller);
            }
         }
         else
         {
            controller = newCell.getChildController("buyableItemInfo");
            if(controller != null)
            {
               controller.setAttribute(BaseWidgetView.ATTRIBUTE_OBSTRUCT,false);
               controller.setAttribute(BaseWidgetView.ATTRIBUTE_VISIBLE,false);
            }
         }
         return newCell;
      }
      
      private function onPurchaseTransactionComplete(event:TransactionEvent) : void
      {
         if(event.transaction is TBuyItemPutGiftbox || event.transaction is TBuyAvatarItem)
         {
            this.enableButtons();
         }
      }
      
      private function enableButtons() : void
      {
         var controller:ButtonController = null;
         for each(controller in this.m_buttonControllers)
         {
            controller.setAttribute(ButtonController.ATTRIBUTE_DISABLED,false);
         }
         TransactionManager.getInstance().removeEventListener(TransactionEvent.COMPLETED,this.onPurchaseTransactionComplete);
      }
      
      private function onBuyButtonPressed(event:WidgetControllerEvent) : void
      {
         var controller:ButtonController = null;
         var purchaseData:Object = null;
         var farmItem:FarmItem = null;
         var avatarItem:AvatarItem = null;
         var confirmationText:String = null;
         for each(controller in this.m_buttonControllers)
         {
            controller.setAttribute(ButtonController.ATTRIBUTE_DISABLED,true);
         }
         controller = event.getController() as ButtonController;
         purchaseData = this.m_purchaseData[controller.index];
         if(purchaseData.item is FarmItem)
         {
            farmItem = purchaseData.item as FarmItem;
            if(farmItem.realCashCost >= PAYMENT_CONFIRMATION_MINIMUM)
            {
               this.m_currentItem = farmItem;
               confirmationText = ZLocUtils.t("Dialogs","FarmCashBuyConfirmation",{"price":farmItem.realCashCost});
               UI.displayMessage(confirmationText,GenericPopup.TYPE_ACCEPTCANCEL,this.onClickAcceptPopup,"farmAnimatedCashConfirmation",true,true);
            }
            else if(Global.player.buyFarmItem(farmItem,Currency.CASH,1,true))
            {
               TransactionManager.getInstance().addEventListener(TransactionEvent.COMPLETED,this.onPurchaseTransactionComplete);
               FarmStatsManager.count("Quest_reward_purchase",farmItem.name,String(farmItem.cash));
            }
            else
            {
               this.enableButtons();
            }
         }
         else if(purchaseData.item is AvatarItem)
         {
            avatarItem = purchaseData.item as AvatarItem;
            AvatarManager.buyAvatarItem(avatarItem.itemId);
         }
      }
      
      public function onClickAcceptPopup(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT && this.m_currentItem != null)
         {
            if(Global.player.buyFarmItem(this.m_currentItem,Currency.CASH,1,true))
            {
               TransactionManager.getInstance().addEventListener(TransactionEvent.COMPLETED,this.onPurchaseTransactionComplete);
               FarmStatsManager.count("Quest_reward_purchase",this.m_currentItem.name,String(this.m_currentItem.cash));
            }
         }
         else if(event.button == GenericPopup.CANCEL)
         {
            this.enableButtons();
         }
      }
      
      override public function setup() : void
      {
         var closeButtonView:BaseWidgetView = null;
         super.setup();
         if(m_questObject != null)
         {
            this.m_rewardList = this.createRewardList();
            this.setUpRewards();
            this.setUpHeaderTexts();
            this.setUpAvatarImageAndMessage();
            this.setUpShareButton();
            closeButtonView = this.getShortcutController("content").getAttribute(ResizeController.ATTRIBUTE_VIEW_TO_PIN);
            if(closeButtonView != null)
            {
               closeButtonView.getController().listen(WidgetControllerEvent.BUTTON_PRESSED,this.onCloseButtonPress);
            }
         }
      }
      
      protected function setUpHeaderTexts() : void
      {
         var controller:BaseWidgetController = null;
         this.setShortcutAttribute("titleText",TextFieldView.ATTRIBUTE_TEXT,m_questObject.titleText);
         this.setShortcutAttribute("completeText",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Quests","Complete"));
         if(this.m_rewardList.length > 0)
         {
            this.setShortcutAttribute("rewardText",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Quests","Reward"));
         }
         else
         {
            controller = this.getShortcutController("rewardText");
            controller.setAttribute(BaseWidgetView.ATTRIBUTE_OBSTRUCT,false);
            controller.setAttribute(BaseWidgetView.ATTRIBUTE_VISIBLE,false);
         }
      }
      
      protected function setUpRewards() : void
      {
         var controller:BaseWidgetController = null;
         if(this.m_rewardList.length > 0)
         {
            controller = this.getShortcutController("rewardCell");
            controller.setAttribute(CellController.ATTRIBUTE_CREATE,this);
            controller.setAttribute(CellController.ATTRIBUTE_CELL_COUNT,this.m_rewardList.length);
         }
         else
         {
            controller = this.getShortcutController("greenBox");
            controller.setAttribute(BaseWidgetView.ATTRIBUTE_OBSTRUCT,false);
            controller.setAttribute(BaseWidgetView.ATTRIBUTE_VISIBLE,false);
         }
      }
      
      protected function createRewardList() : Array
      {
         var rewardList:Array = [];
         var rewardIndex:int = 0;
         var totalPossibleRewards:int = int(m_questObject.rewards.length);
         var rewardImageUrl:String = "";
         var rewardQuantityString:String = "";
         var rewardObj:Object = null;
         for(rewardIndex = 0; rewardIndex < totalPossibleRewards; rewardIndex++)
         {
            rewardImageUrl = m_questObject.getImageForRewardAtIndex(rewardIndex);
            if(rewardImageUrl != null && rewardImageUrl != "")
            {
               rewardObj = {};
               rewardObj[URL_KEY] = rewardImageUrl;
               rewardObj[QUANTITY_KEY] = m_questObject.getValueForRewardAtIndex(rewardIndex);
               rewardList.push(rewardObj);
            }
         }
         return rewardList;
      }
      
      protected function getAvatarImage() : String
      {
         return m_questObject.avatarBodyImage;
      }
      
      private function setUpAvatarImageAndMessage() : void
      {
         this.setShortcutAttribute("avatarImage",ImageController.ATTRIBUTE_SOURCE,this.getAvatarImage());
         this.setShortcutAttribute("avatarText",TextFieldView.ATTRIBUTE_TEXT,m_questObject.rewardText);
      }
      
      private function setUpShareButton() : void
      {
         if(m_questObject.friendRewardItem)
         {
            this.setShortcutAttribute("shareButton",ButtonController.ATTRIBUTE_TEXT,m_questObject.rewardShareButtonText);
            this.setShortcutListener("shareButton",WidgetControllerEvent.BUTTON_PRESSED,this.onShareButtonPress);
         }
         else
         {
            this.setShortcutAttribute("shareButton",BaseWidgetView.ATTRIBUTE_OBSTRUCT,false);
            this.setShortcutAttribute("shareButton",BaseWidgetView.ATTRIBUTE_VISIBLE,false);
         }
      }
      
      private function onShareButtonPress(event:WidgetControllerEvent) : void
      {
         TransactionManager.addTransaction(new TShareQuestLoot(m_questObject.name,true,this),true);
         event.getController().setAttribute(ButtonController.ATTRIBUTE_DISABLED,true);
      }
      
      public function postRewardFeed(rewardLink:String) : void
      {
         var creativeBundleName:String = null;
         var item:FarmItem = null;
         var bundleData:Object = null;
         if(rewardLink != null)
         {
            creativeBundleName = m_questObject.creativeBundleName;
            item = m_questObject.friendRewardItem;
            if(creativeBundleName != null && creativeBundleName != "" && item != null)
            {
               bundleData = {
                  "actor":Global.player.firstName,
                  "reward_link":rewardLink,
                  "item_name":item.friendlyName,
                  "images":[{
                     "src":Global.getAssetURL(m_questObject.completeShareFeedIcon),
                     "href":Config.SN_APP_URL + rewardLink
                  }]
               };
               GlobalEngine.socialNetwork.publishFeedStory(creativeBundleName,bundleData,[],false);
            }
         }
      }
      
      private function onCloseButtonPress(event:WidgetControllerEvent) : void
      {
         TransactionManager.addTransaction(new TShareQuestLoot(m_questObject.name,false,this),true);
      }
      
      override public function destroy() : void
      {
         FarmQuestManager.getInstance().onQuestRewardDialogClosed();
         super.destroy();
      }
   }
}

