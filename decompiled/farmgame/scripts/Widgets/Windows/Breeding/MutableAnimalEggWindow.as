package Widgets.Windows.Breeding
{
   import Classes.FeatureDataObjects.FriendSet;
   import Classes.FeatureDataObjects.MysteryEggFriendSet;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.GenericXMLDialog;
   import Display.ImpulseBuy;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Events.ImpulseBuyEvent;
   import Transactions.TCompleteFriendSet;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Breeding.MutableAnimalEggSlotFrame;
   import Widgets.Windows.FarmWindow;
   import com.troyer.widget.MT4DManager;
   import com.troyer.widget.event.WidgetControllerEvent;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class MutableAnimalEggWindow extends FarmWindow
   {
      
      public var m_mysteryEggFriendSet:MysteryEggFriendSet;
      
      public var m_fsId:int;
      
      private var m_buyCostCash:Number = 20;
      
      private var m_buyButton:FarmAnimatedTextButton = null;
      
      private var m_askButton:FarmAnimatedTextButton = null;
      
      private var m_buyDialog:GenericPopup = null;
      
      private var m_impulseBuyDialog:ImpulseBuy = null;
      
      private var m_friendSlotFrame:MutableAnimalEggSlotFrame = null;
      
      private var m_whatIsThisButton:FarmAnimatedTextButton = null;
      
      private var m_itemFeatureFriendSet:MysteryEggFriendSet = null;
      
      private var m_itemFeatureFriendResult:Object = null;
      
      public var m_totalFriendsRequired:Number = 6;
      
      public function MutableAnimalEggWindow(data:Object)
      {
         this.m_fsId = data.fsId;
         super("assets/dialogs/FV_animal_egg.swf");
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs","AviaryEggWindowTitle")));
         addWidget(new ZwTextField(m_window.generic_0_tf,ZLocUtils.t("Dialogs","AviaryEggWindowText1")));
         addWidget(new ZwTextField(m_window.generic_1_tf,ZLocUtils.t("Dialogs","AviaryEggWindowText2")));
         this.m_buyButton = new FarmAnimatedTextButton(m_window.buy_bt,ZLocUtils.t("Dialogs","craftingWorkshop_recipeIndicator_desc"),this.onBuyClick);
         addWidget(this.m_buyButton,false);
         this.m_askButton = new FarmAnimatedTextButton(m_window.ask_bt,ZLocUtils.t("Dialogs","Generic_Ask"),this.onAskClick);
         addWidget(this.m_askButton,false);
         this.m_whatIsThisButton = new FarmAnimatedTextButton(m_window.whatisthis_bt,ZLocUtils.t("Dialogs","HowDoesThisWork"),this.howDoesThisWorkClick);
         addWidget(this.m_whatIsThisButton);
         this.m_friendSlotFrame = new MutableAnimalEggSlotFrame(m_window.friends_mc,[],this);
         addWidget(this.m_friendSlotFrame);
         this.featureSetRefresh();
      }
      
      public function featureSetRefresh() : void
      {
         this.m_mysteryEggFriendSet = FriendSet.factory(MysteryEggFriendSet.MYSTERY_EGG_CODE,this.m_fsId,this.featureSetUpdate) as MysteryEggFriendSet;
         this.m_mysteryEggFriendSet.initializeData();
      }
      
      private function featureSetUpdate(itemFeatureFriendSetIn:FriendSet, result:Object) : void
      {
         var friendData:Array = null;
         var boughtFriendCount:int = 0;
         var _uid:String = null;
         var numHelpers:int = 0;
         var countTemp:* = 0;
         this.m_buyButton.visible = true;
         this.m_askButton.visible = true;
         var extraFriendsHelp:int = 0;
         if(m_window != null)
         {
            this.m_itemFeatureFriendSet = itemFeatureFriendSetIn as MysteryEggFriendSet;
            this.m_itemFeatureFriendResult = result;
            friendData = [];
            boughtFriendCount = Math.max(Math.min(int(this.m_itemFeatureFriendResult.boughtFriendCount),this.m_totalFriendsRequired),0);
            for(_uid in this.m_itemFeatureFriendResult.uids)
            {
               if(friendData.length < this.m_totalFriendsRequired && this.m_itemFeatureFriendResult.uids[_uid] == "1")
               {
                  friendData.push({"uid":_uid.replace("_","")});
               }
            }
            numHelpers = int(friendData.length);
            countTemp = boughtFriendCount;
            while(friendData.length < this.m_totalFriendsRequired)
            {
               if(countTemp > 0)
               {
                  friendData.push({"uid":"bought"});
                  countTemp--;
               }
               else
               {
                  friendData.push({"uid":""});
               }
            }
            this.m_askButton.visible = true;
            this.m_buyButton.visible = true;
            extraFriendsHelp = friendData.length - this.m_totalFriendsRequired;
            this.m_friendSlotFrame.setData(friendData);
            this.m_friendSlotFrame.refresh();
            this.m_friendSlotFrame.updateExtraHelpers(extraFriendsHelp);
         }
      }
      
      private function onBuyClick(event:MouseEvent) : void
      {
         var popUpMessage:String = null;
         this.m_buyButton.enabled = false;
         if(Global.player.cash >= this.m_buyCostCash)
         {
            popUpMessage = ZLocUtils.t("Dialogs","LonelyAnimal_DialogBuy",{
               "animalName":"mystery egg",
               "quantity":this.m_buyCostCash
            });
            this.m_buyDialog = new GenericPopup(popUpMessage,GenericPopup.TYPE_ACCEPTCANCEL,this.onBuyClose);
            UI.displayPopup(this.m_buyDialog,false);
         }
         else
         {
            this.m_impulseBuyDialog = UI.displayImpulseBuyPopup(ImpulseBuy.TYPE_MARKET_CASH,"impulseBuyPopup",this.m_buyCostCash,"mystery_egg");
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
      
      private function onBuyClose(evt:GenericPopupEvent) : void
      {
         if(evt.button == GenericPopup.ACCEPT)
         {
            TransactionManager.addTransaction(new TCompleteFriendSet(this.m_mysteryEggFriendSet,function():void
            {
               close();
            }),true);
            this.m_buyDialog = null;
         }
         else
         {
            this.m_buyButton.enabled = true;
         }
      }
      
      private function onImpulseBuyCancel(event:Event) : void
      {
         if(this.m_impulseBuyDialog)
         {
            this.m_buyButton.enabled = true;
            this.m_impulseBuyDialog.removeEventListener(ImpulseBuyEvent.CANCEL,this.onImpulseBuyCancel);
            this.m_impulseBuyDialog = null;
         }
         else
         {
            this.m_buyButton.enabled = true;
            MT4DManager.getInstance().removeEventListener(WidgetControllerEvent.DIALOG_DESTROY,this.onImpulseBuyCancel);
         }
      }
      
      private function onAskClick(event:MouseEvent) : void
      {
      }
      
      private function howDoesThisWorkClick(event:MouseEvent) : void
      {
         var msg:String = ZLocUtils.t("Dialogs","",{"quantity":1});
         var dialog:GenericXMLDialog = new GenericXMLDialog(null,null,null,null,NaN,NaN,msg,null,false,"Okay",null,null,null,null,GenericXMLDialog.NUM_DIALOG_WIDTH_MEDIUM);
         UI.displayPopup(dialog,false);
      }
   }
}

