package Classes.Avatar
{
   import Managers.PartyManager;
   
   public class PartyAvatar extends FriendAvatar
   {
      
      protected static const MENU_ACCEPT:String = "partyAvatarAccept";
      
      protected static const MENU_CANCEL:String = "partyAvatarCancel";
      
      private static const FADE_OUT_TIME_IN_SEC:int = 2;
      
      protected var m_code:String;
      
      public function PartyAvatar(friendId:String, code:String)
      {
         super(friendId);
         this.m_code = code;
      }
      
      override protected function getLayerName() : String
      {
         return PartyManager.PARTY_AVATAR_LAYER;
      }
      
      override public function onClick() : void
      {
         PartyManager.getInstance().fadeOutAllPartyAvatars(this.m_code);
      }
   }
}

