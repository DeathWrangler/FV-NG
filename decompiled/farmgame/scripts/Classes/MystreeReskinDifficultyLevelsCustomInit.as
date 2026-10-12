package Classes
{
   import Managers.FeatureMessagingManager;
   import Managers.MystreeReskinDifficultyLevelsManager;
   
   public class MystreeReskinDifficultyLevelsCustomInit implements IFeatureMessagingCustomInit
   {
      
      private var m_featureName:String;
      
      public function MystreeReskinDifficultyLevelsCustomInit(xml:XML)
      {
         super();
         this.m_featureName = xml.attribute("name").toString();
      }
      
      public function initialize() : void
      {
         var mystreeReskinDifficultyLevelsManager:MystreeReskinDifficultyLevelsManager = new MystreeReskinDifficultyLevelsManager(this.m_featureName);
         FeatureMessagingManager.getInstance().registerFeatureInitialized(this.m_featureName,mystreeReskinDifficultyLevelsManager.showMainWindow);
      }
   }
}

