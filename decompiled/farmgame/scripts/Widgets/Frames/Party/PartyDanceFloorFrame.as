package Widgets.Frames.Party
{
   import Classes.Avatar.PartyAvatarUI;
   import Managers.PartyManager;
   import Widgets.Core.Frames.ZwFrame;
   import flash.display.DisplayObject;
   import flash.utils.Dictionary;
   
   public class PartyDanceFloorFrame extends ZwFrame
   {
      
      public static const MAX_PARTY_AVATARS:Number = 40;
      
      protected var m_partyCode:String;
      
      public function PartyDanceFloorFrame(element:DisplayObject, code:String = "FS01")
      {
         super(element);
         this.m_partyCode = code;
         this.buildDanceFloorFrame();
      }
      
      protected function buildDanceFloorFrame() : void
      {
         var uid:String = null;
         var friendPartyAvatar:PartyAvatarUI = null;
         var mcName:String = null;
         var element:Object = this.element;
         var partyFriends:Dictionary = PartyManager.getInstance().getPartyObjectByCode(this.m_partyCode).friendSet.friends;
         var numPartyFriends:Number = 0;
         for(uid in partyFriends)
         {
            if(numPartyFriends < MAX_PARTY_AVATARS && partyFriends[uid] > 0)
            {
               friendPartyAvatar = new PartyAvatarUI(uid);
               numPartyFriends++;
               mcName = "AvIcon_" + numPartyFriends + "_mc";
               if(element.hasOwnProperty(mcName))
               {
                  element[mcName].addChild(friendPartyAvatar);
                  element[mcName].visible = true;
                  friendPartyAvatar.doRandomDance();
               }
            }
         }
      }
   }
}

