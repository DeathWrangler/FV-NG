package Managers
{
   import Classes.Idle.IdleTaskQueue;
   import Classes.Idle.NPCPromoTask;
   import Classes.NPC;
   import Classes.NPCConfigData;
   
   public class NPCManager
   {
      
      private static var TOASTER_SEEN_FLAG_PREFIX:String = "SeenNPCPromoToaster";
      
      public static const NPC_CITYVILLE_LAUNCH:String = "CityVilleNPC";
      
      public static const NPC_EMPIRE_AND_ALLIES_LAUNCH:String = "EmpireAlliesNPC";
      
      public static const NPC_FRONTIER_PIONEER:String = "FTPioneerTrailNPC";
      
      public static const NPC_ADVENTURE_LAUNCH:String = "adventure_xpromoNPC";
      
      public static const NPC_WORLD_TRAVEL:String = "WorldTravelNPC";
      
      public static const NPC_COMMUNITY_NEIGHBORS:String = "CommunityNeighborsNPC";
      
      private static var m_initialized:Boolean = false;
      
      private static var m_instance:NPCManager = null;
      
      private var m_activeNpc:NPC = null;
      
      protected var m_npcs:Array = [];
      
      protected var m_isVisitingNPC:Boolean = false;
      
      public function NPCManager()
      {
         super();
         if(!m_initialized)
         {
            m_initialized = true;
            return;
         }
         throw new Error("Error: Instantiation failed: Use NPCManager.getInstance() instead of new.");
      }
      
      public static function getInstance() : NPCManager
      {
         if(m_instance == null)
         {
            m_instance = new NPCManager();
         }
         return m_instance;
      }
      
      public function get activeNpc() : NPC
      {
         return this.m_activeNpc;
      }
      
      public function set activeNpc(npc:NPC) : void
      {
         this.m_activeNpc = npc;
      }
      
      public function get npcs() : Array
      {
         return this.m_npcs;
      }
      
      public function set isVisitingNPC(value:Boolean) : void
      {
         if(value)
         {
            IdleTaskQueue.getInstance().togglePause(true);
            ToasterManager.getInstance().togglePause(true);
            if(Global.player.avatar)
            {
               Global.player.avatar.hideAvatar();
            }
         }
         else
         {
            IdleTaskQueue.getInstance().togglePause(false);
            ToasterManager.getInstance().togglePause(false);
            if(Global.player.avatar)
            {
               Global.player.avatar.showAvatar();
            }
         }
         this.m_isVisitingNPC = value;
      }
      
      public function get isVisitingNPC() : Boolean
      {
         return this.m_isVisitingNPC;
      }
      
      public function addNPC(npcConfig:NPCConfigData) : void
      {
         this.m_npcs.push(npcConfig);
         this.setupNPCWindows(npcConfig);
         if(npcConfig.assets)
         {
            NPC.preloadAssetsStatic(npcConfig);
         }
      }
      
      public function getModelFarmVisitId() : String
      {
         var npc:NPCConfigData = null;
         var result:String = null;
         for each(npc in this.m_npcs)
         {
            if(npc.type == NPCConfigData.TYPE_MODELFARM)
            {
               result = npc.id;
            }
         }
         return result;
      }
      
      private function setupNPCWindows(npcConfig:NPCConfigData) : void
      {
         if(this.canDisplayToaster(npcConfig))
         {
            IdleTaskQueue.getInstance().addTask(new NPCPromoTask(npcConfig));
         }
      }
      
      public function getNPC(npcid:String) : NPCConfigData
      {
         var npc:NPCConfigData = null;
         var npcData:NPCConfigData = null;
         for each(npc in this.m_npcs)
         {
            if(npc.id == npcid)
            {
               npcData = npc;
               break;
            }
         }
         return npcData;
      }
      
      public function visitFarm(npcid:String) : void
      {
         var npcConfig:NPCConfigData = this.getNPC(npcid);
         this.setToasterSeenFlag(npcConfig);
         this.isVisitingNPC = true;
         Global.worldManager.visitNPC(npcid);
      }
      
      public function canDisplayToaster(npcConfig:NPCConfigData) : Boolean
      {
         var seenFlag:String = null;
         var result:Boolean = false;
         if(npcConfig != null)
         {
            switch(npcConfig.name)
            {
               case NPC_CITYVILLE_LAUNCH:
                  result = false;
                  break;
               default:
                  seenFlag = TOASTER_SEEN_FLAG_PREFIX + npcConfig.name;
                  result = !Global.player.getSeenFlag(seenFlag);
            }
         }
         return result;
      }
      
      public function setToasterSeenFlag(npcConfig:NPCConfigData) : void
      {
         var toasterSeenFlag:String = TOASTER_SEEN_FLAG_PREFIX + npcConfig.name;
         Global.player.setSeenFlag(toasterSeenFlag);
      }
      
      public function launchShareFeed(npcid:String) : void
      {
         var promo:NPCConfigData = this.getNPC(npcid);
         var promoName:String = promo.name;
         var feedImage:String = Global.farmGameSettingsManager.getString("promoFarmFeedIcon_" + promoName);
         var bundleData:Object = {
            "item_name":"",
            "images":[{
               "href":"{SN_APP_URL}{creative:picture}index.php",
               "src":Global.getAssetURL(feedImage)
            }]
         };
         GlobalEngine.socialNetwork.publishFeedStory(promoName + "_Completed",bundleData,[],false);
         FarmStatsManager.count("feed",promoName);
      }
   }
}

