package Classes
{
   import Classes.ZItem.FarmItem;
   import Classes.unwither.UnwitherUtils;
   import Classes.util.ZLocUtils;
   import Display.CustomizeRing;
   import Display.FriendSelector;
   import Display.GenericPopup;
   import Display.ImpulseBuy;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.CloseEvent;
   import Events.GenericPopupEvent;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Transactions.TBuyAndSendPresent;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class BuyPresent extends MovieClip
   {
      
      protected var m_present:FarmItem = null;
      
      private var m_itemContext:String = null;
      
      protected var m_friendSelector:FriendSelector;
      
      protected var m_customizeRing:CustomizeRing;
      
      protected var m_CustomRingWhatIsThis:GenericPopup;
      
      protected var m_friendList:Array;
      
      protected var m_overviewPopup:GenericPopup;
      
      protected var m_closeCallback:Function = null;
      
      public function BuyPresent(itemName:String, itemContext:String, closeCallback:Function = null)
      {
         var msg:String = null;
         super();
         this.m_present = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         this.m_itemContext = itemContext;
         this.m_closeCallback = closeCallback;
         if(this.isSpecialValentinesGift(this.m_present))
         {
            msg = ZLocUtils.t("Dialogs","CustomRingWhatIsThis");
            this.m_CustomRingWhatIsThis = new GenericPopup(msg,GenericPopup.TYPE_ACCEPTCANCEL,this.onCustomRingWhatIsThisClose,GenericPopup.GENERIC_ASSET_LRG);
            this.m_CustomRingWhatIsThis.setAcceptTextName("NextCap");
            UI.displayPopup(this.m_CustomRingWhatIsThis,false,"howDoesThisWorkPopup",true);
         }
         else
         {
            this.m_friendSelector = new FriendSelector();
            this.m_friendSelector.setTitle("PresentFriendSelectorTitle");
            this.m_friendSelector.addEventListener(CloseEvent.CLOSE,this.onFriendSelectorClose);
            UI.displayPopup(this.m_friendSelector,false);
         }
      }
      
      private function isSpecialValentinesGift(item:FarmItem) : Boolean
      {
         var isValentineGift:Boolean = false;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            isValentineGift = item.getBoolFromDataSource("specialValentinesItem");
         }
         else
         {
            isValentineGift = Boolean(item.xml.@specialValentinesItem) && true == item.xml.@specialValentinesItem;
         }
         return isValentineGift;
      }
      
      protected function onCustomRingWhatIsThisClose(event:GenericPopupEvent) : void
      {
         var filteredArray:Array = null;
         var ringWorld:String = null;
         var friendArray:Array = null;
         var aFriend:Friend = null;
         var aWorld:String = null;
         if(event.button == GenericPopup.YES)
         {
            filteredArray = new Array();
            if(this.m_present)
            {
               ringWorld = UnwitherUtils.getUnwitherWorldfromCode(this.m_present.code);
               friendArray = Global.friendManager.neighbors;
               for each(aFriend in friendArray)
               {
                  if(aFriend.unlockedWorldTypes)
                  {
                     for each(aWorld in aFriend.unlockedWorldTypes)
                     {
                        if(aWorld == ringWorld)
                        {
                           filteredArray.push(aFriend);
                        }
                     }
                  }
                  else if(aFriend.worldName == ringWorld)
                  {
                     filteredArray.push(aFriend);
                  }
               }
            }
            this.m_friendSelector = new FriendSelector(false,0,0,false,null,null,filteredArray);
            this.m_friendSelector.setTitle("PresentFriendSelectorTitle");
            this.m_friendSelector.setNextDetailText("ValentinesPresentNextDetail");
            this.m_friendSelector.addEventListener(CloseEvent.CLOSE,this.onFriendSelectorClose);
            UI.displayPopup(this.m_friendSelector,false);
            FarmStatsManager.count("Farmville_DiamondRing","Buyflow","Step_2");
         }
         else
         {
            dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
         }
         this.m_CustomRingWhatIsThis = null;
         if(this.m_closeCallback != null)
         {
            this.m_closeCallback();
         }
      }
      
      protected function onFriendSelectorClose(event:Event) : void
      {
         var friendName:String = null;
         var friendGender:String = null;
         var msg:String = null;
         this.m_friendSelector.removeEventListener(CloseEvent.CLOSE,this.onFriendSelectorClose);
         this.m_friendList = this.m_friendSelector.getSelectedFriends();
         this.m_friendSelector = null;
         if(this.m_friendList.length > 0)
         {
            if(this.isSpecialValentinesGift(this.m_present))
            {
               this.m_customizeRing = new CustomizeRing(this.m_present,this.m_friendList[0]);
               this.m_customizeRing.addEventListener(CloseEvent.CLOSE,this.onCustomizeRingClose);
               UI.displayPopup(this.m_customizeRing,false);
               FarmStatsManager.count("Farmville_DiamondRing","Buyflow","Step_3");
            }
            else
            {
               friendName = (this.m_friendList[0] as IUser).name;
               friendGender = (this.m_friendList[0] as IUser).snUser.gender;
               msg = ZLocUtils.t("Dialogs","PresentSendOverview",{
                  "item":ZLocUtils.tk_pk(this.m_present.friendlyName),
                  "user":ZLocUtils.tn(friendName,ZLocUtils.tg(friendGender)),
                  "quantity":this.m_present.realCashCost
               });
               this.m_overviewPopup = new GenericPopup(msg,GenericPopup.TYPE_ACCEPTCANCEL,this.onOverviewPopupClose);
               UI.displayPopup(this.m_overviewPopup,false);
            }
         }
         else
         {
            dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
         }
         if(this.m_closeCallback != null)
         {
            this.m_closeCallback();
         }
      }
      
      protected function onOverviewPopupClose(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.YES)
         {
            if(Global.player.cash >= this.m_present.realCashCost)
            {
               TransactionManager.addTransaction(new TBuyAndSendPresent(this.m_present,this.m_friendList,this.m_itemContext),true);
            }
            else
            {
               UI.displayImpulseBuyPopup(ImpulseBuy.TYPE_MARKET_CASH,"impulseBuyPopup",this.m_present.realCashCost,this.m_present.type);
               FarmStatsManager.count("fv_buyableGift","not_enough_cash");
            }
         }
         else
         {
            FarmStatsManager.count("fv_buyableGift","cancel_to_pay");
         }
         dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
         this.m_overviewPopup = null;
         if(this.m_closeCallback != null)
         {
            this.m_closeCallback();
         }
      }
      
      protected function onCustomizeRingClose(event:Event) : void
      {
         this.m_customizeRing.removeEventListener(CloseEvent.CLOSE,this.onCustomizeRingClose);
         var extraItemData:Object = this.m_customizeRing.getCustomRingData();
         this.m_customizeRing = null;
         if(null != extraItemData)
         {
            if(Global.player.cash < this.m_present.cash)
            {
               UI.displayImpulseBuyPopup(ImpulseBuy.TYPE_MARKET_CASH,"impulseBuyPopup",this.m_present.cash,this.m_present.type);
               FarmStatsManager.count("Farmville_DiamondRing","Buyflow","not_enough_cash");
            }
            else
            {
               TransactionManager.addTransaction(new TBuyAndSendPresent(this.m_present,this.m_friendList,TBuyAndSendPresent.ITEMCONTEXT_NORMAL,extraItemData),true);
               FarmStatsManager.count("Farmville_DiamondRing","Buyflow","Complete");
               FarmStatsManager.count("Farmville_DiamondRing","Ringversion",extraItemData.ringType);
               FarmStatsManager.count("Farmville_DiamondRing","Msglength",(extraItemData.message as String).length.toString());
            }
         }
         dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
         if(this.m_closeCallback != null)
         {
            this.m_closeCallback();
         }
      }
   }
}

