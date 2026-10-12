package Widgets.Windows.LonelyAnimal
{
   import Classes.FeatureDataObjects.FriendSet;
   import Classes.FeatureDataObjects.LonelyAnimalFeatureFriendSet;
   import Classes.LonelyAnimal;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.ImpulseBuy;
   import Display.UI;
   import Engine.Managers.LoadingManager;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Events.ImpulseBuyEvent;
   import Managers.FarmStatsManager;
   import Transactions.TCompleteFriendSet;
   import Transactions.TMarkLonelyAnimalFriendSet;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.FarmWindow;
   import com.troyer.widget.MT4DManager;
   import com.troyer.widget.event.WidgetControllerEvent;
   import flash.display.Loader;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class LonelyAnimalCompletionWindow extends FarmWindow
   {
      
      private var m_dialogType:Boolean = true;
      
      private var m_cashNeeded:Number;
      
      private var m_lonelyAnimal:LonelyAnimal;
      
      private var m_buyDialog:GenericPopup = null;
      
      private var m_impulseBuyDialog:ImpulseBuy = null;
      
      private var m_friendSet:LonelyAnimalFeatureFriendSet = null;
      
      private var m_buyButton:FarmAnimatedTextButton;
      
      private var m_shareButton:FarmAnimatedTextButton;
      
      private var m_cancelButton:FarmAnimatedTextButton;
      
      private var m_description:ZwTextField;
      
      public function LonelyAnimalCompletionWindow(success:Boolean, friendSet:LonelyAnimalFeatureFriendSet, lonelyAnimal:LonelyAnimal, cash:Number = 0)
      {
         this.m_dialogType = success;
         this.m_friendSet = friendSet;
         this.m_lonelyAnimal = lonelyAnimal;
         this.m_cashNeeded = cash;
         if(success)
         {
            FarmStatsManager.count("lonely_animal_crew_feature","animal_asset","click_return_access");
            this.m_friendSet.completionSeen();
         }
         super("assets/dialogs/FV_LonelyAnimal_Game_Completion.swf");
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         addWidget(new ZwTextField(m_window.header_tf,ZLocUtils.t("Dialogs","LonelyAnimal_Title")));
         this.m_description = new ZwTextField(m_window.generic0_tf,"");
         addWidget(this.m_description);
         this.m_cancelButton = new FarmAnimatedTextButton(m_window.cancel_bt,"",this.onCancel);
         addWidget(this.m_cancelButton);
         this.m_buyButton = new FarmAnimatedTextButton(m_window.buy_bt,ZLocUtils.t("Dialogs","BuyNow"),this.onBuyClick);
         addWidget(this.m_buyButton,false);
         this.m_shareButton = new FarmAnimatedTextButton(m_window.share_bt,ZLocUtils.t("Dialogs","Share"),this.onShare);
         addWidget(this.m_shareButton,false);
         addWidget(new ZwBaseWidget(m_window.icon_mc));
         this.updateElements();
      }
      
      private function updateElements(itemFeatureFriendSetIn:FriendSet = null, result:Object = null) : void
      {
         var item:FarmItem = this.m_lonelyAnimal.getItem();
         if(this.m_dialogType)
         {
            this.m_friendSet.completionSeen();
            this.m_description.text = ZLocUtils.t("Dialogs","LonelyAnimal_CompleteSuccess",{
               "animalName":ZLocUtils.tk_pk_asTitle(item.friendlyName),
               "animalName2":ZLocUtils.tk_pk_asTitle(item.friendlyName)
            });
            this.m_cancelButton.text = ZLocUtils.t("Dialogs","NoThanks");
            this.setImage(item.getIconUrlFromActiveData());
            this.m_shareButton.visible = true;
            this.m_buyButton.visible = false;
            FarmStatsManager.count("lonely_animal_crew_feature","success_dialog","impression");
         }
         else
         {
            this.m_description.text = ZLocUtils.t("Dialogs","LonelyAnimal_CompleteFailure",{
               "animalName":ZLocUtils.tk_pk_asTitle(item.friendlyName),
               "price":this.m_cashNeeded,
               "animalName2":ZLocUtils.tk_pk_asTitle(item.friendlyName)
            });
            this.m_cancelButton.text = ZLocUtils.t("Dialogs","Cancel");
            this.setImage(item.getIconUrlFromActiveData());
            this.m_shareButton.visible = false;
            this.m_buyButton.visible = true;
            FarmStatsManager.count("lonely_animal_crew_feature","failure_dialog","impression");
         }
      }
      
      private function onShare(event:Event) : void
      {
         var bundleData:Object = null;
         var messageType:String = null;
         var farmItem:FarmItem = this.m_lonelyAnimal.getItem();
         if(farmItem)
         {
            bundleData = {
               "reward_name":farmItem.friendlyName,
               "reward_link":this.m_friendSet.rewardLink,
               "images":[{
                  "href":"{SN_APP_URL}" + this.m_friendSet.rewardLink,
                  "src":farmItem.icon
               }]
            };
            messageType = "LonelyAnimalFinished";
            GlobalEngine.socialNetwork.publishFeedStory(messageType,bundleData,[],false);
         }
         TransactionManager.addTransaction(new TMarkLonelyAnimalFriendSet(this.m_friendSet,TMarkLonelyAnimalFriendSet.LONELY_ANIMAL_PROGRESS_END));
         Global.player.setFeatureLastShown(LonelyAnimal.LONELY_ANIMAL_SEEN_FLAG,GlobalEngine.currentTime,false);
         this.m_lonelyAnimal.hideAnimal();
         this.close();
      }
      
      private function onBuyClick(event:MouseEvent) : void
      {
         var popUpMessage:String = null;
         var dialogStats:String = null;
         this.m_buyButton.enabled = false;
         var item:FarmItem = this.m_lonelyAnimal.getItem();
         if(Global.player.cash >= this.m_cashNeeded)
         {
            popUpMessage = ZLocUtils.t("Dialogs","LonelyAnimal_DialogBuy",{
               "animalName":ZLocUtils.tk_pk_asTitle(item.friendlyName),
               "quantity":this.m_cashNeeded
            });
            this.m_buyDialog = new GenericPopup(popUpMessage,GenericPopup.TYPE_ACCEPTCANCEL,this.onBuyClose);
            UI.displayPopup(this.m_buyDialog,false);
         }
         else
         {
            if(this.m_dialogType)
            {
               dialogStats = "success_dialog";
            }
            else
            {
               dialogStats = "failure_dialog";
            }
            FarmStatsManager.count("lonely_animal_crew_feature",dialogStats,"hire_help","no_FC");
            this.m_impulseBuyDialog = UI.displayImpulseBuyPopup(ImpulseBuy.TYPE_MARKET_CASH,"impulseBuyPopup",this.m_cashNeeded,item.type);
            if(this.m_impulseBuyDialog != null)
            {
               this.m_impulseBuyDialog.addEventListener(ImpulseBuyEvent.CANCEL,this.onImpulseBuyCancel);
            }
            else
            {
               MT4DManager.getInstance().addEventListener(WidgetControllerEvent.DIALOG_DESTROY,this.onImpulseBuyCancel);
            }
         }
      }
      
      private function onImpulseBuyCancel(event:Event) : void
      {
         if(this.m_impulseBuyDialog)
         {
            this.m_impulseBuyDialog.removeEventListener(ImpulseBuyEvent.CANCEL,this.onImpulseBuyCancel);
            this.m_impulseBuyDialog = null;
         }
         else
         {
            this.m_buyButton.enabled = true;
            MT4DManager.getInstance().removeEventListener(WidgetControllerEvent.DIALOG_DESTROY,this.onImpulseBuyCancel);
         }
      }
      
      private function onBuyClose(evt:GenericPopupEvent) : void
      {
         var dialogStats:String = null;
         this.m_buyButton.enabled = true;
         if(this.m_dialogType)
         {
            dialogStats = "success_dialog";
         }
         else
         {
            dialogStats = "failure_dialog";
         }
         if(evt.button == GenericPopup.ACCEPT)
         {
            TransactionManager.addTransaction(new TCompleteFriendSet(this.m_friendSet,this.featureSetRefresh),true);
            this.m_buyDialog = null;
            FarmStatsManager.count("fv_cash_buy","animal",this.m_lonelyAnimal.getItem().name,"" + this.m_cashNeeded);
            FarmStatsManager.count("lonely_animal_feature",dialogStats,"has_FC","accept");
         }
         else
         {
            this.m_buyDialog = null;
            FarmStatsManager.count("lonely_animal_feature",dialogStats,"has_FC","cancel");
         }
      }
      
      public function featureSetRefresh() : void
      {
         this.m_friendSet = FriendSet.factory(LonelyAnimal.LONELY_ANIMAL_FRIENDSET_CODE,this.m_friendSet.index,this.updateElements) as LonelyAnimalFeatureFriendSet;
         this.m_friendSet.initializeData();
         this.m_friendSet.completionSeen();
         this.m_dialogType = true;
      }
      
      private function onCancel(event:Event) : void
      {
         var dialogStats:String = null;
         Global.player.setFeatureLastShown(LonelyAnimal.LONELY_ANIMAL_SEEN_FLAG,GlobalEngine.currentTime,false);
         TransactionManager.addTransaction(new TMarkLonelyAnimalFriendSet(this.m_friendSet,TMarkLonelyAnimalFriendSet.LONELY_ANIMAL_PROGRESS_END));
         this.m_lonelyAnimal.hideAnimal();
         if(this.m_dialogType)
         {
            dialogStats = "success_dialog";
         }
         else
         {
            dialogStats = "failure_dialog";
         }
         FarmStatsManager.count("lonely_animal_crew_feature",dialogStats,"no_thanks");
         this.close();
      }
      
      private function setImage(url:String = "") : void
      {
         var icon:Loader = null;
         icon = LoadingManager.load(url,function(event:Event):void
         {
            var dispObj:* = undefined;
            if(Boolean(icon) && Boolean(icon.content))
            {
               dispObj = icon.content;
               m_window.icon_mc.addChild(dispObj);
            }
         });
      }
   }
}

