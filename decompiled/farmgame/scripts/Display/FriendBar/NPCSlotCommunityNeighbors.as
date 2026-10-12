package Display.FriendBar
{
   import Classes.IUser;
   import Classes.NPC;
   import Engine.Managers.LoadingManager;
   import Managers.FarmStatsManager;
   import Managers.MFSRequestManager;
   import flash.events.MouseEvent;
   
   public class NPCSlotCommunityNeighbors extends NPCSlot
   {
      
      public function NPCSlotCommunityNeighbors(slotIndex:int)
      {
         super(slotIndex);
         FarmStatsManager.count("farmville_friends","neighbor_bar_card","impressions");
      }
      
      override public function onClickFriend(event:MouseEvent) : void
      {
         MFSRequestManager.getInstance().displayR2AddNeighborWindow();
         FarmStatsManager.count("commuinty_neighbors","neighbor_bar_hook","hook");
      }
      
      override public function updateSlot(friend:IUser, rank:int, level:int, xp:int, avatarData:Object, statsObj:Object, fakeFriend:Boolean = false, emptySlot:Boolean = false, isLoading:Boolean = false) : void
      {
         super.updateSlot(friend,rank,level,xp,null,null);
         LoadingManager.load(Global.getAssetURL((friend as NPC).getFriendBarImage()),onNPCFriendImageLoad);
      }
   }
}

