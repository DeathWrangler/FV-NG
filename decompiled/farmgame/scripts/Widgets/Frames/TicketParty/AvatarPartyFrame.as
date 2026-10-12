package Widgets.Frames.TicketParty
{
   import Classes.Avatar.PartyAvatarUI;
   import Widgets.Core.Frames.ZwFrame;
   import flash.display.DisplayObject;
   
   public class AvatarPartyFrame extends ZwFrame
   {
      
      public function AvatarPartyFrame(element:DisplayObject, partyMembers:Array, playRandomAnimation:Boolean = true)
      {
         var uid:String = null;
         var friendPartyAvatar:PartyAvatarUI = null;
         var mcName:String = null;
         super(element);
         var numPartyFriends:Number = 0;
         for each(uid in partyMembers)
         {
            friendPartyAvatar = new PartyAvatarUI(uid);
            mcName = "AvIcon_" + numPartyFriends + "_mc";
            if(!element.hasOwnProperty(mcName))
            {
               break;
            }
            element[mcName].addChild(friendPartyAvatar);
            element[mcName].visible = true;
            friendPartyAvatar.changeDirection(numPartyFriends % 2);
            if(playRandomAnimation)
            {
               friendPartyAvatar.doRandomDance();
            }
            numPartyFriends++;
         }
      }
   }
}

