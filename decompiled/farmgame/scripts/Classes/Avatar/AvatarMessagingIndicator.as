package Classes.Avatar
{
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import MyLife.Character;
   import Widgets.Windows.ArrowIndicatorWindow;
   import Widgets.Windows.MessageIndicatorWindow;
   import flash.display.DisplayObject;
   
   public class AvatarMessagingIndicator
   {
      
      protected var m_usingLoadingGraphic:Boolean = false;
      
      protected var m_targetAvatar:FarmAvatar;
      
      protected var m_arrow_indicator:ArrowIndicatorWindow;
      
      protected var m_message_indicator:MessageIndicatorWindow;
      
      protected var m_targetCharacter:Character;
      
      protected var m_targetDisplayObject:DisplayObject = null;
      
      protected var m_hideMessaging:Boolean = false;
      
      protected var m_messagingCurrentlyHidden:Boolean = true;
      
      public function AvatarMessagingIndicator(target:DisplayObject, targetCharacter:Character, avatar:FarmAvatar)
      {
         super();
         this.m_targetDisplayObject = target;
         this.m_targetCharacter = targetCharacter;
         this.m_targetAvatar = avatar;
      }
      
      private static function shouldDisplayIndicator(avatar:FarmAvatar) : Boolean
      {
         return false;
      }
      
      private static function countEvent(phylumKey:String, classKey:String = "") : void
      {
         FarmStatsManager.count("neighbor_visit",phylumKey,classKey);
      }
      
      public static function countSeesIndicator() : void
      {
         countEvent("comm_neighbor_action","avatar_neighbor_hover");
      }
      
      public static function countClicksIndicator() : void
      {
         countEvent("comm_neighbor_action","avatar_neighbor_click");
      }
      
      private function createArrowIndicator() : void
      {
         var arrowIndicator:DisplayObject = null;
         var title:String = ZLocUtils.t("Dialogs","AvatarMessagingIndicator_Title_0");
         var text:String = ZLocUtils.t("Dialogs","AvatarMessagingIndicator_Text_0");
         var iconUrl:String = "assets/hud/IndicatorArrows/signpost_indicator_icon.png";
         this.m_arrow_indicator = new ArrowIndicatorWindow(iconUrl,title,text);
         this.setArrowPosition();
      }
      
      private function createMessageIndicator() : void
      {
         var messageIndicator:DisplayObject = null;
         var text:String = ZLocUtils.t("Dialogs","AvatarMessagingIndicator_Text_0");
         this.m_message_indicator = new MessageIndicatorWindow(text);
         this.setMessagePosition();
      }
      
      public function removeMessagingIndicator() : Boolean
      {
         return false;
      }
      
      public function showRolloverEffect(show:Boolean) : void
      {
         if(this.m_arrow_indicator)
         {
            this.m_arrow_indicator.showRolloverText(show);
         }
         if(this.m_message_indicator)
         {
            this.m_message_indicator.showRolloverEffect(show);
         }
         countSeesIndicator();
      }
      
      protected function setArrowPosition() : void
      {
         this.m_arrow_indicator.x = -this.m_targetCharacter.width * 0.5;
         this.m_arrow_indicator.y = -Math.max(240,this.m_targetCharacter.height + this.m_arrow_indicator.height);
      }
      
      protected function setMessagePosition() : void
      {
         this.m_message_indicator.x = -this.m_targetCharacter.width * 1.17;
         this.m_message_indicator.y = -Math.max(190,-this.m_targetCharacter.height + this.m_message_indicator.height);
      }
   }
}

