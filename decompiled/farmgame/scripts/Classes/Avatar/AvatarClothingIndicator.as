package Classes.Avatar
{
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import MyLife.Character;
   import Widgets.Windows.ArrowIndicatorWindow;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class AvatarClothingIndicator
   {
      
      private static var m_consecutiveSessions:int;
      
      private static var m_nextAllowedDisplayTime:int;
      
      public static const AVATAR_SURFACING_THROTTLE_FEATURE_NAME:String = "AvatarSurfaceThrottle";
      
      public static const AVATAR_SURFACING_CONSECUTIVE_SESSIONS_FEATURE_NAME:String = "AvatarClothingIndicatorConsecutiveSessions";
      
      public static const AVATAR_SURFACING_LAST_SHOWN_FEATURE_NAME:String = "AvatarClothingIndicatorDisplay";
      
      public static const AVATAR_SURFACING_LAST_PURCHASE_FEATURE_NAME:String = "AvatarItemPurchased";
      
      public static const AVATAR_SURFACING_LAST_INTERACTION_FEATURE_NAME:String = "AvatarIndicatorLastInteraction";
      
      public static const AVATAR_INDICATOR_X_POSITION_OFFSET_FACTOR:Number = 0.5;
      
      public static const AVATAR_INDICATOR_Y_POSITION_OFFSET_MAX:int = 240;
      
      public static const AVATAR_SURFACING_BACKOFF_CAP:int = 4;
      
      public static const MAX_SEEN_COUNT_PER_ITEM:int = 2;
      
      public static const SURFACE_FREQUENCY:int = 3;
      
      public static const SURFACE_THROTTLE_DAYS:int = 7;
      
      private static const INDICATOR_HIDE_TIME:int = 60000;
      
      private static var m_alreadyIncrementedSeenCount:Boolean = false;
      
      private var m_surfacingEnabled:Boolean = true;
      
      private var m_surfacingFrequency:int = 3;
      
      private var m_surfacingItem:String;
      
      public var m_xButtonHighlighted:Boolean = false;
      
      protected var m_usingLoadingGraphic:Boolean = false;
      
      protected var m_targetAvatar:FarmAvatar;
      
      protected var m_arrow_indicator:ArrowIndicatorWindow;
      
      protected var m_targetCharacter:Character;
      
      protected var m_targetDisplayObject:DisplayObject = null;
      
      protected var m_hideArrow:Boolean = false;
      
      protected var m_arrowCurrentlyHidden:Boolean = true;
      
      private var m_hideIndicatorTimer:Timer = null;
      
      private var m_featuredItem:AvatarItem;
      
      private var m_indicatorHasBeenDisplayed:Boolean = false;
      
      private var m_avatarSurfacingUsed:Boolean = false;
      
      public function AvatarClothingIndicator(target:DisplayObject, targetCharacter:Character, avatar:FarmAvatar)
      {
         super();
         this.m_surfacingEnabled = Global.player.avatarSurfacingEnabled;
         if(Global.player.avatarSurfacingFrequency > -1)
         {
            this.m_surfacingFrequency = Global.player.avatarSurfacingFrequency;
         }
         this.m_surfacingItem = Global.player.avatarSurfacingItem;
         this.m_targetDisplayObject = target;
         this.m_targetCharacter = targetCharacter;
         this.m_targetAvatar = avatar;
         this.drawDisplayObject(false);
      }
      
      private static function countEvent(avatar:FarmAvatar, phylumKey:String, classKey:String = "") : void
      {
         if(Global.player.getSeenSessionFlag("avatarIndicator"))
         {
            FarmStatsManager.count("IndicatorArrow_Present",phylumKey,classKey);
         }
      }
      
      public static function countSeesIndicator(avatar:FarmAvatar) : void
      {
         countEvent(avatar,"Sees_IndicatorArrow");
      }
      
      public static function countClicksIndicator(avatar:FarmAvatar) : void
      {
         countEvent(avatar,"Clicks_IndicatorArrow");
      }
      
      public static function countTriesOnClothing(avatar:FarmAvatar) : void
      {
         countEvent(avatar,"Tries_on");
      }
      
      public static function countUsesItem(avatar:FarmAvatar) : void
      {
         countEvent(avatar,"Tries_on");
      }
      
      public static function countBuysWithCash(avatar:FarmAvatar) : void
      {
         countEvent(avatar,"Buys_item","Cash_item");
         Global.player.setFeatureLastShown(AVATAR_SURFACING_LAST_PURCHASE_FEATURE_NAME,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,true);
         Global.player.resetBackoffInterval(AVATAR_SURFACING_THROTTLE_FEATURE_NAME);
      }
      
      public static function countBuysWithCoins(avatar:FarmAvatar) : void
      {
         countEvent(avatar,"Buys_item","Coin_item");
      }
      
      public static function countExit(avatar:FarmAvatar) : void
      {
         countEvent(avatar,"Exit");
      }
      
      private static function getNewClothingItem(avatar:FarmAvatar) : AvatarItem
      {
         var avatarItem:AvatarItem = Global.avatarConfigSettings.getFeaturedAvatarItem(avatar.gender);
         if(avatarItem == null || !Global.player.avatarState.canBuy(avatarItem.itemId,true))
         {
            return null;
         }
         return avatarItem;
      }
      
      public function drawDisplayObject(visible:Boolean = true) : void
      {
         var spr:Sprite = this.m_targetDisplayObject as Sprite;
         if(!this.m_indicatorHasBeenDisplayed)
         {
            if(this.shouldDisplayIndicator(this.m_targetAvatar) && Boolean(spr))
            {
               if(this.m_arrow_indicator == null && spr.numChildren > 0)
               {
                  this.m_indicatorHasBeenDisplayed = true;
                  this.createArrowIndicator();
               }
            }
         }
         if(Boolean(this.m_arrow_indicator) && Boolean(spr))
         {
            spr.addChild(this.m_arrow_indicator);
            this.setArrowPosition();
            this.m_arrow_indicator.visible = visible;
         }
         this.m_arrowCurrentlyHidden = !visible;
      }
      
      private function shouldDisplayIndicator(avatar:FarmAvatar) : Boolean
      {
         var key:String = null;
         var seenCount:int = 0;
         var indicatorLastShown:Number = NaN;
         var lastItemPurchased:Number = NaN;
         var lastIndicatorInteraction:Number = NaN;
         var checkBackoffCap:Boolean = false;
         var checkIsPayer:Boolean = false;
         var checkNotBackedOff:Boolean = false;
         var lastPurchaseMinDaysAgo:Boolean = false;
         var checkLastInteraction:Boolean = false;
         var shownMoreThanFrequencyDaysAgo:Boolean = false;
         var notExceededMaxCount:Boolean = false;
         var shouldDisplay:Boolean = true;
         var newItem:AvatarItem = getNewClothingItem(avatar);
         if(shouldDisplay && newItem != null)
         {
            key = "avatarIndicatorItem" + newItem.itemId;
            seenCount = Global.player.getActionCount(key);
            shouldDisplay = seenCount < MAX_SEEN_COUNT_PER_ITEM;
         }
         if(this.m_surfacingEnabled)
         {
            m_consecutiveSessions = Global.player.getActionCount(AVATAR_SURFACING_CONSECUTIVE_SESSIONS_FEATURE_NAME) % (MAX_SEEN_COUNT_PER_ITEM + 1);
            indicatorLastShown = Global.player.getFeatureLastShown(AVATAR_SURFACING_LAST_SHOWN_FEATURE_NAME);
            lastItemPurchased = Global.player.getFeatureLastShown(AVATAR_SURFACING_LAST_PURCHASE_FEATURE_NAME);
            lastIndicatorInteraction = Global.player.getFeatureLastShown(AVATAR_SURFACING_LAST_INTERACTION_FEATURE_NAME);
            checkBackoffCap = Global.player.getBackoffInterval(AVATAR_SURFACING_THROTTLE_FEATURE_NAME) < AVATAR_SURFACING_BACKOFF_CAP;
            checkIsPayer = Global.player.totalCashPurchased > 0;
            checkNotBackedOff = Global.player.canShowFeatureWithBackoff(AVATAR_SURFACING_THROTTLE_FEATURE_NAME);
            lastPurchaseMinDaysAgo = lastItemPurchased + this.m_surfacingFrequency * FarmGameUtil.NUM_SECS_IN_DAY < GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            checkLastInteraction = lastIndicatorInteraction + this.m_surfacingFrequency * FarmGameUtil.NUM_SECS_IN_DAY < GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            shownMoreThanFrequencyDaysAgo = indicatorLastShown + this.m_surfacingFrequency * FarmGameUtil.NUM_SECS_IN_DAY < GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            notExceededMaxCount = m_consecutiveSessions < MAX_SEEN_COUNT_PER_ITEM;
            if((!shouldDisplay || newItem == null) && checkBackoffCap && checkIsPayer && checkNotBackedOff && lastPurchaseMinDaysAgo && checkLastInteraction && (shownMoreThanFrequencyDaysAgo || notExceededMaxCount))
            {
               newItem = Global.avatarConfigSettings.randomSurfacableItem(Global.player.avatar.gender);
               shouldDisplay = true;
               Global.player.incrementActionCount(AVATAR_SURFACING_CONSECUTIVE_SESSIONS_FEATURE_NAME);
               this.m_avatarSurfacingUsed = true;
            }
            shouldDisplay &&= newItem != null;
            if(shouldDisplay)
            {
               Global.player.setFeatureLastShown(AVATAR_SURFACING_LAST_SHOWN_FEATURE_NAME,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,true);
            }
         }
         if(shouldDisplay)
         {
            this.m_featuredItem = newItem;
         }
         else
         {
            while(Global.player.getActionCount(AVATAR_SURFACING_CONSECUTIVE_SESSIONS_FEATURE_NAME) % (MAX_SEEN_COUNT_PER_ITEM + 1) != 0)
            {
               Global.player.incrementActionCount(AVATAR_SURFACING_CONSECUTIVE_SESSIONS_FEATURE_NAME);
            }
         }
         Global.player.setAvatarArrowIndicatorVisible(shouldDisplay);
         return shouldDisplay;
      }
      
      private function timeOutHideIndicator(event:TimerEvent) : void
      {
         this.removeArrowIndicator();
      }
      
      public function xButtonOver(event:MouseEvent) : void
      {
         this.m_xButtonHighlighted = true;
      }
      
      public function xButtonOut(event:MouseEvent) : void
      {
         this.m_xButtonHighlighted = false;
      }
      
      public function closeOutIndicator() : void
      {
         this.removeArrowIndicator();
         Global.player.incrementBackoffInterval(AVATAR_SURFACING_THROTTLE_FEATURE_NAME);
         FarmStatsManager.count("IndicatorArrow_Present","Action","Exit");
      }
      
      private function createArrowIndicator() : void
      {
         var title:String = null;
         var text:String = null;
         var avatarItem:AvatarItem = this.m_featuredItem;
         if(!avatarItem)
         {
            return;
         }
         var arrowIndicator:DisplayObject = null;
         title = ZLocUtils.t("Dialogs","AvatarClothingIndicator_Title_" + avatarItem.itemId);
         text = ZLocUtils.t("Dialogs","AvatarClothingIndicator_Text_" + avatarItem.itemId);
         if(this.m_avatarSurfacingUsed || title == "" && text == "")
         {
            title = ZLocUtils.t("Dialogs","AvatarClothingIndicator_Title_Default");
            text = ZLocUtils.t("Dialogs","AvatarClothingIndicator_Text_Default");
         }
         var iconUrl:String = avatarItem.iconPath;
         this.m_arrow_indicator = new ArrowIndicatorWindow(iconUrl,title,text);
         this.m_arrow_indicator.setupCloseButton(this.xButtonOver,this.xButtonOut);
         this.setArrowPosition();
         var key:String = "avatarIndicatorItem" + avatarItem.itemId;
         Global.player.incrementActionCount(key,true);
         Global.player.setSeenSessionFlag("avatarIndicator");
         countSeesIndicator(this.m_targetAvatar);
         if(this.m_hideIndicatorTimer == null)
         {
            this.m_hideIndicatorTimer = new Timer(INDICATOR_HIDE_TIME,1);
            this.m_hideIndicatorTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.timeOutHideIndicator);
         }
         this.m_hideIndicatorTimer.start();
      }
      
      public function removeArrowIndicator() : Boolean
      {
         var shouldRedraw:Boolean = false;
         if(Boolean(this.m_arrow_indicator) && Boolean(this.m_arrow_indicator.visible) && this.m_arrow_indicator.parent != null)
         {
            if(this.m_hideIndicatorTimer != null)
            {
               this.m_hideIndicatorTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.timeOutHideIndicator);
               this.m_hideIndicatorTimer = null;
            }
            this.m_arrow_indicator.destroyCloseButton();
            this.m_xButtonHighlighted = false;
            this.m_arrow_indicator.visible = false;
            this.m_arrow_indicator.parent.removeChild(this.m_arrow_indicator);
            this.m_arrow_indicator = null;
            this.m_arrowCurrentlyHidden = true;
            this.m_hideArrow = true;
            shouldRedraw = true;
         }
         return shouldRedraw;
      }
      
      public function showRolloverText(show:Boolean) : void
      {
         if(this.m_arrow_indicator)
         {
            this.m_arrow_indicator.showRolloverText(show);
         }
      }
      
      protected function setArrowPosition() : void
      {
         this.m_arrow_indicator.x = -this.m_targetCharacter.width * AVATAR_INDICATOR_X_POSITION_OFFSET_FACTOR;
         this.m_arrow_indicator.y = -Math.max(AVATAR_INDICATOR_Y_POSITION_OFFSET_MAX,this.m_targetCharacter.height + this.m_arrow_indicator.height);
      }
   }
}

