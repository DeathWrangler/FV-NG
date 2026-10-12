package Display.FriendBar
{
   import Classes.Constants.CrossPromoConstants;
   import Classes.IUser;
   import Classes.NPC;
   import Classes.NPCConfigData;
   import Classes.TutController;
   import Classes.util.ZLocUtils;
   import Display.FarmGameSprite;
   import Engine.Managers.LoadingManager;
   import Managers.NPCManager;
   import flash.display.Bitmap;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class NPCSlot extends FriendBarSlot
   {
      
      protected var m_sprite:FarmGameSprite;
      
      public function NPCSlot(slotIndex:int)
      {
         super(slotIndex);
      }
      
      public static function factory(npcData:NPCConfigData, index:int) : NPCSlot
      {
         var npcSlot:NPCSlotWorldTravel = null;
         var npcName:String = npcData.name;
         var result:NPCSlot = null;
         switch(npcName)
         {
            case NPCManager.NPC_CITYVILLE_LAUNCH:
               result = new NPCSlotCityvilleLaunch(index);
               break;
            case NPCManager.NPC_EMPIRE_AND_ALLIES_LAUNCH:
               result = new NPCSlotEmpiresAlliesLaunch(index);
               break;
            case NPCManager.NPC_COMMUNITY_NEIGHBORS:
               result = new NPCSlotCommunityNeighbors(index);
               break;
            case NPCManager.NPC_FRONTIER_PIONEER:
               result = new NPCSlotFrontierPioneerLaunch(index);
               break;
            case NPCManager.NPC_ADVENTURE_LAUNCH:
               result = new NPCCrossPromo(index,npcName,CrossPromoConstants.GAME_IDS[CrossPromoConstants.ADVENTURE_PROMO_NAME]);
               break;
            case NPCManager.NPC_WORLD_TRAVEL:
               npcSlot = new NPCSlotWorldTravel(index,npcData);
               if(npcSlot.shouldDisplay())
               {
                  result = npcSlot;
               }
               break;
            default:
               result = new NPCSlot(index);
         }
         return result;
      }
      
      override public function onClickFriend(event:MouseEvent) : void
      {
         if(Boolean(Global.worldManager.getVisiting() != uid) && Boolean(this.m_sprite) && TutController.hasFinishedTutorial())
         {
            this.m_sprite.hideToolTip();
            NPCManager.getInstance().visitFarm(uid);
         }
      }
      
      override protected function onRollOutFriend(e:MouseEvent) : void
      {
      }
      
      override protected function onRollOverFriend(e:MouseEvent) : void
      {
         if(this.m_sprite != null && Global.worldManager.getVisiting() == uid)
         {
            this.m_sprite.hideToolTip();
         }
      }
      
      override protected function setupName() : void
      {
      }
      
      override public function updateSlot(friend:IUser, rank:int, level:int, xp:int, avatarData:Object, statsObj:Object, fakeFriend:Boolean = false, emptySlot:Boolean = false, isLoading:Boolean = false) : void
      {
         super.updateSlot(friend,rank,level,xp,null,null);
         this.loadNPCFriendImage();
      }
      
      protected function loadNPCFriendImage() : void
      {
         LoadingManager.load(Global.getAssetURL((friend as NPC).getFriendBarImage()),this.onNPCFriendImageLoad);
      }
      
      public function onNPCFriendImageLoad(event:Event) : void
      {
         var loadedBackImage:Bitmap = event.target.content as Bitmap;
         this.m_sprite = new FarmGameSprite();
         loadedBackImage.y += 7;
         this.m_sprite.addChild(loadedBackImage);
         this.m_sprite.toolTip = ZLocUtils.t("Dialogs","PromoFarmNeighborBar_tooltip_" + uid);
         addChild(this.m_sprite);
      }
      
      override protected function setupXP() : void
      {
      }
   }
}

