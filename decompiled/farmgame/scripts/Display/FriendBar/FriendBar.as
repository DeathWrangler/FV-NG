package Display.FriendBar
{
   import Classes.Constants.ClickTrackingConstants;
   import Classes.CrossPromoDescriptor;
   import Classes.Friend;
   import Classes.IUser;
   import Classes.NPC;
   import Classes.NPCConfigData;
   import Engine.Classes.SocialNetworkUser;
   import Engine.Managers.ErrorManager;
   import Events.FriendBarEvent;
   import Events.FriendBarSlotEvent;
   import Managers.ClickTrackingManager;
   import Managers.FarmStatsManager;
   import Managers.NPCManager;
   import flash.display.Sprite;
   import flash.utils.setTimeout;
   import gs.TweenLite;
   
   public class FriendBar extends Sprite
   {
      
      private static const NUM_EMPTY_NEIGHBORS:int = 8;
      
      protected const Y_POS:int = 345;
      
      private var m_slots:Array = [];
      
      private var m_excludedSlots:Array = [];
      
      private var m_filter:String = "";
      
      public function FriendBar()
      {
         super();
      }
      
      protected function onSlotClick(e:FriendBarSlotEvent) : void
      {
         ClickTrackingManager.getInstance().countClick(ClickTrackingConstants.CLICK_TYPE_UI);
         e.stopImmediatePropagation();
         e.stopPropagation();
         var clickedSlot:FriendBarSlot = e.currentTarget as FriendBarSlot;
         if(clickedSlot.uid != Global.player.uid)
         {
            dispatchEvent(new FriendBarSlotEvent(FriendBarSlotEvent.FRIEND_BAR_SLOT_CLICK,clickedSlot,"friendbar","contextual","slot"));
         }
      }
      
      public function get slots() : Array
      {
         return this.m_slots;
      }
      
      public function get allSlots() : Array
      {
         return this.m_slots.concat(this.m_excludedSlots);
      }
      
      public function populateNeighbors(friends:Array, hasLoadedSNData:Boolean = true) : void
      {
         var friend:IUser = null;
         var i:int = 0;
         var emptyFriend:Friend = null;
         var numSlots:int = int(this.m_slots.length);
         if(this.m_slots != null && numSlots > 0)
         {
            for(i = 0; i < numSlots; i++)
            {
               if(this.m_slots[i] is FriendBarSlot)
               {
                  (this.m_slots[i] as FriendBarSlot).visible = false;
               }
               this.m_slots[i] = null;
            }
         }
         this.m_slots = [];
         var npcsPresent:int = 0;
         for(var index:int = 0; index < NUM_EMPTY_NEIGHBORS; index++)
         {
            emptyFriend = new Friend(null,null,true,true);
            friends.unshift(emptyFriend);
         }
         var showLoading:Boolean = !hasLoadedSNData;
         var slotIdx:int = 0;
         for(slotIdx = 0; slotIdx < friends.length; slotIdx++)
         {
            this.setupSlot(new FriendBarSlot(slotIdx),slotIdx);
            friend = friends[slotIdx];
            if(friend.uid == "0" || friend != null && this.m_slots[slotIdx] != null)
            {
               this.m_slots[slotIdx].updateSlot(friend,friends.length - slotIdx,Global.farmGameSettingsManager.getLevelForXP(friend.xp),friend.xp,friend.avatarData,friend.cardStats,friend.fake,friend.empty,showLoading);
            }
            else
            {
               ErrorManager.addError("friend is null");
            }
         }
         npcsPresent = this.addNPCSlots();
         slotIdx += npcsPresent;
         dispatchEvent(new FriendBarEvent(FriendBarEvent.LOADED,undefined,(friends.length + npcsPresent) * FriendBarSlot.SLOT_WIDTH_INTERVAL));
      }
      
      private function addNPCSlots() : int
      {
         var slot:NPCSlot = null;
         var crossPromo:CrossPromoDescriptor = null;
         var npcIndex:* = 0;
         var npcData:NPCConfigData = null;
         var npcs:Array = NPCManager.getInstance().npcs;
         var npcsPresent:int = 0;
         var slotIdx:int = int(this.m_slots.length);
         if(npcs != null && npcs.length > 0)
         {
            npcIndex = int(npcs.length - 1);
            while(npcIndex >= 0 && npcsPresent < this.getMaxVisibleNPCsSlots())
            {
               npcData = npcs[npcIndex];
               slot = NPCSlot.factory(npcData,slotIdx);
               if(slot)
               {
                  this.addNPCSlot(slot,slotIdx,npcData.id);
                  FarmStatsManager.sample(100,npcData.stat,"neighborbar_impression");
                  npcsPresent++;
                  slotIdx++;
               }
               npcIndex--;
            }
         }
         var activeCrossPromos:Object = Global.crosspromoDescriptorManager.crossPromos;
         for each(crossPromo in activeCrossPromos)
         {
            if(crossPromo.hasNpc())
            {
               slot = new NPCCrossPromoDescriptor(slotIdx,crossPromo);
               this.addNPCSlot(slot,slotIdx,crossPromo.npcId);
               npcsPresent++;
               slotIdx++;
            }
         }
         return npcsPresent;
      }
      
      private function addNPCSlot(slot:NPCSlot, slotIdx:int, npcId:String) : void
      {
         this.setupSlot(slot,slotIdx);
         var friend:IUser = new NPC(npcId);
         this.m_slots[slotIdx].updateSlot(friend,slotIdx,int.MAX_VALUE,int.MAX_VALUE,null,null);
      }
      
      private function getMaxVisibleNPCsSlots() : int
      {
         return Global.farmGameSettingsManager.getInt("neighborsMaxVisibleNPCSlots",0);
      }
      
      public function updatePlayerSocialData(snUser:SocialNetworkUser) : void
      {
         var slot:FriendBarSlot = null;
         for(var slotIdx:uint = 0; slotIdx < this.m_slots.length; slotIdx++)
         {
            slot = this.m_slots[slotIdx];
            if(slot.uid == snUser.uid)
            {
               slot.friend.snUser = snUser;
               slot.updateSlotFriend(slot.friend);
               break;
            }
         }
      }
      
      public function updatePlayerAvatar(playerId:String, avatarCustomizationData:Object, gender:int) : void
      {
         var slot:FriendBarSlot = null;
         for(var slotIdx:uint = 0; slotIdx < this.m_slots.length; slotIdx++)
         {
            slot = this.m_slots[slotIdx];
            if(slot.uid == playerId)
            {
               slot.updateSlotAvatar(avatarCustomizationData,gender);
               break;
            }
         }
      }
      
      public function addSlotAtBeginning(slot:FriendBarSlot) : void
      {
         if(slot != null)
         {
            slot.buttonMode = true;
            slot.x = (this.m_slots.length - 1) * FriendBarSlot.SLOT_WIDTH_INTERVAL;
            slot.y = this.Y_POS;
            slot.addEventListener(FriendBarSlotEvent.FRIEND_BAR_SLOT_CLICK,this.onSlotClick);
            this.m_slots.push(slot);
            addChild(slot);
            slot.alpha = 0;
            TweenLite.to(slot,1,{
               "alpha":1,
               "delay":1.5
            });
            this.refreshSlotsView();
         }
      }
      
      public function removeSlotAtIndex(index:int) : void
      {
         var slot:FriendBarSlot = null;
         var i:int = 0;
         var friendSlot:FriendBarSlot = null;
         slot = this.m_slots[index] as FriendBarSlot;
         if(slot)
         {
            slot.removeEventListener(FriendBarSlotEvent.FRIEND_BAR_SLOT_CLICK,this.onSlotClick);
            TweenLite.to(slot,1,{
               "alpha":0,
               "onComplete":function():void
               {
                  removeChild(slot);
               }
            });
            for(i = 0; i < this.m_slots.length; i++)
            {
               friendSlot = this.m_slots[i];
               if(i > index)
               {
                  --friendSlot.index;
               }
            }
            this.m_slots.splice(index,1);
            this.refreshSlotsView();
         }
      }
      
      public function removeSlotByUid(uid:String) : void
      {
         var i:int;
         var slot:FriendBarSlot = null;
         var friendSlot:FriendBarSlot = null;
         var slotIndex:int = 0;
         slot = null;
         for(i = 0; i < this.m_slots.length; i++)
         {
            friendSlot = this.m_slots[i];
            if(friendSlot.uid == uid)
            {
               slot = friendSlot;
               break;
            }
         }
         if(slot != null)
         {
            slotIndex = slot.index;
            slot.removeEventListener(FriendBarSlotEvent.FRIEND_BAR_SLOT_CLICK,this.onSlotClick);
            TweenLite.to(slot,1,{
               "alpha":0,
               "onComplete":function():void
               {
                  removeChild(slot);
               }
            });
            this.m_slots.splice(slotIndex,1);
            this.refreshSlotsView();
         }
      }
      
      private function setupSlot(slot:FriendBarSlot, index:int) : void
      {
         slot.buttonMode = true;
         slot.x = index * FriendBarSlot.SLOT_WIDTH_INTERVAL;
         slot.y = this.Y_POS;
         slot.addEventListener(FriendBarSlotEvent.FRIEND_BAR_SLOT_CLICK,this.onSlotClick);
         this.m_slots.push(slot);
         slot.m_index = index;
         addChild(slot);
      }
      
      public function filterFriendsByString(filter:String = "") : void
      {
         var excludedSlot:FriendBarSlot = null;
         var newSlots:Array = null;
         var slot:FriendBarSlot = null;
         var slotId:String = null;
         for each(excludedSlot in this.m_excludedSlots)
         {
            excludedSlot.visible = true;
         }
         this.m_slots = this.m_slots.concat(this.m_excludedSlots);
         this.m_excludedSlots = new Array();
         this.m_filter = filter;
         if(this.m_filter != "")
         {
            this.m_filter = this.m_filter.toLowerCase();
            newSlots = new Array();
            for each(slot in this.m_slots)
            {
               if(slot.friend != null && (slot.friend.name.toLowerCase().indexOf(this.m_filter) >= 0 || (slot.friend.empty || slot.friend.fake)))
               {
                  slotId = String(slot.uid);
                  if(slotId != Global.player.uid)
                  {
                     newSlots.push(slot);
                  }
               }
               else
               {
                  slot.visible = false;
                  this.m_excludedSlots.push(slot);
               }
            }
            this.m_slots = newSlots;
         }
         this.m_slots.sort(FriendBarSlot.onlineStatusSort);
         this.refreshSlotsView();
      }
      
      public function autoSortStart() : void
      {
         var futureSlots:Array = null;
         var resort:Boolean = false;
         var i:int = 0;
         var searchUid:String = null;
         var j:int = 0;
         var newX:int = 0;
         if(this.m_filter == "")
         {
            futureSlots = this.m_slots.concat();
            futureSlots.sort(FriendBarSlot.onlineStatusSort);
            resort = false;
            for(i = 0; i < this.m_slots.length; i++)
            {
               searchUid = this.m_slots[i].uid;
               if(searchUid != "0")
               {
                  for(j = 0; j < futureSlots.length; j++)
                  {
                     if(futureSlots[j].uid == searchUid)
                     {
                        newX = j * FriendBarSlot.SLOT_WIDTH_INTERVAL;
                        TweenLite.to(this.m_slots[i],0.3,{"x":newX});
                        resort = true;
                     }
                  }
               }
            }
            if(resort)
            {
               setTimeout(this.autoSortDone,300);
            }
         }
      }
      
      public function autoSortDone() : void
      {
         this.m_slots.sort(FriendBarSlot.onlineStatusSort);
         this.refreshSlotsView(false);
      }
      
      public function shuffleSlots() : void
      {
         var array2:Array = [];
         while(this.m_slots.length > 0)
         {
            array2.push(this.m_slots.splice(Math.round(Math.random() * (this.m_slots.length - 1)),1)[0]);
         }
         this.m_slots = array2;
         this.m_slots.pop();
         this.refreshSlotsView();
      }
      
      private function refreshSlotsView(resetScroll:Boolean = true) : void
      {
         var slot:FriendBarSlot = null;
         for(var index:int = 0; index < this.m_slots.length; index++)
         {
            slot = this.m_slots[index];
            slot.x = index * FriendBarSlot.SLOT_WIDTH_INTERVAL;
            slot.m_index = index;
         }
         dispatchEvent(new FriendBarEvent(FriendBarEvent.LOADED,undefined,this.m_slots.length * FriendBarSlot.SLOT_WIDTH_INTERVAL,resetScroll));
      }
      
      public function refreshFriendSlots() : void
      {
         var index:int = 0;
         var friendSlot:FriendBarSlot = null;
         var removeFriends:Array = [];
         for(index = 0; index < this.m_slots.length; index++)
         {
            friendSlot = this.m_slots[index];
            if(friendSlot is NPCSlot && !(friendSlot is DynamicNPCSlot))
            {
               removeFriends.push(friendSlot);
            }
         }
         while(removeFriends.length > 0)
         {
            friendSlot = removeFriends.pop();
            this.removeSlotAtIndex(friendSlot.m_index);
         }
         this.m_slots.sort(FriendBarSlot.onlineStatusSort);
         this.addNPCSlots();
         for(index = 0; index < this.m_slots.length; index++)
         {
            friendSlot = this.m_slots[index];
            if(!(friendSlot is NPCSlot) && !friendSlot.friend.fake)
            {
               friendSlot.updateXP();
            }
         }
         this.refreshSlotsView();
      }
   }
}

