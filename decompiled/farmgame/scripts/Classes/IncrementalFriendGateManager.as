package Classes
{
   import flash.utils.Dictionary;
   
   public class IncrementalFriendGateManager
   {
      
      private static var m_instance:IncrementalFriendGateManager;
      
      private var m_featureMinLevels:Dictionary;
      
      public function IncrementalFriendGateManager()
      {
         var thisGate:XML = null;
         var gateName:String = null;
         var gateMinLevel:int = 0;
         super();
         this.m_featureMinLevels = new Dictionary();
         var rawXml:XML = Global.farmGameSettingsManager.getXML();
         var gates:XMLList = rawXml.incrementalFriendGates.friendGate;
         for(var i:int = 0; i < gates.length(); i++)
         {
            thisGate = gates[i];
            gateName = String(thisGate.@name);
            gateMinLevel = int(thisGate.@minLevel);
            this.m_featureMinLevels[gateName] = gateMinLevel;
         }
      }
      
      public static function getInstance() : IncrementalFriendGateManager
      {
         if(m_instance == null)
         {
            m_instance = new IncrementalFriendGateManager();
         }
         return m_instance;
      }
      
      public function checkAllFeatures(player:Player) : void
      {
         var featureName:String = null;
         var requiredLevel:int = 0;
         var incrementalFriendChecks:Dictionary = player.incrementalFriendChecks;
         for(featureName in this.m_featureMinLevels)
         {
            requiredLevel = int(this.m_featureMinLevels[featureName]);
            if(incrementalFriendChecks[featureName] == null && player.level >= requiredLevel)
            {
               incrementalFriendChecks[featureName] = Global.friendManager.neighborCount;
            }
         }
      }
      
      public function getBaseLineFriendsForFeature(featureName:String, player:Player) : int
      {
         this.checkAllFeatures(player);
         var result:int = 0;
         if(player.incrementalFriendChecks != null && player.incrementalFriendChecks[featureName] != null)
         {
            result = int(player.incrementalFriendChecks[featureName]);
         }
         return result;
      }
   }
}

