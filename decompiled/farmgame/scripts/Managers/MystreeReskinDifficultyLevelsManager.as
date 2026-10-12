package Managers
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Widgets.Windows.MystreeReskinDifficultyLevelWindow;
   import Widgets.Windows.MystreeReskinSwitchConfirmationWindow;
   import flash.utils.Dictionary;
   
   public class MystreeReskinDifficultyLevelsManager extends DifficultyLevelManager
   {
      
      private static const SERVICE_NAME:String = "MystreeReskinDifficultyLevelService";
      
      public static const FEATURE_OPTIONS_KEY:String = "mystreereskin";
      
      public static const STAGE_COMPLETION_KEY:String = "stageComplete";
      
      protected static var m_instance:Dictionary = new Dictionary();
      
      public function MystreeReskinDifficultyLevelsManager(featureName:String)
      {
         m_featureName = featureName;
         m_ServiceClassName = SERVICE_NAME;
         m_featureOptionKey = FEATURE_OPTIONS_KEY;
         super();
      }
      
      public static function getInstance(featureName:String) : MystreeReskinDifficultyLevelsManager
      {
         if(!m_instance)
         {
            m_instance = new Dictionary();
         }
         if(!m_instance.hasOwnProperty(featureName))
         {
            m_instance[featureName] = new MystreeReskinDifficultyLevelsManager(featureName);
         }
         return m_instance[featureName] as MystreeReskinDifficultyLevelsManager;
      }
      
      public function showMainWindow() : void
      {
         if(getCurrentDifficultyLevel() != -1)
         {
            MystreeReskinManagerWithEMH.getInstance(m_featureName).openMystreeUI();
         }
         else
         {
            this.showDifficultyMainWindow();
            FarmStatsManager.count(m_featureName,"Difficulty Screen","View","First Time");
         }
      }
      
      public function showDifficultyMainWindow() : void
      {
         UI.displayPopup(new MystreeReskinDifficultyLevelWindow(m_staticData.UIDifficultyDialog,m_featureName));
      }
      
      private function getSwitchConfirmationBodyText(selectedDifficulty:String) : String
      {
         var featureOptionData:Object = null;
         var stageCompletion:String = null;
         var confirmationText:String = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,windowName + "_switch_reConfirmationText");
         if(selectedDifficulty != null)
         {
            featureOptionData = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY,m_featureName);
            stageCompletion = STAGE_COMPLETION_KEY + selectedDifficulty;
            if(Boolean(featureOptionData) && featureOptionData[stageCompletion] == 1)
            {
               confirmationText = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,windowName + "_switch_reConfirmationText2");
            }
         }
         if(!featureOptionData)
         {
            confirmationText = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,windowName + "_switch_reConfirmationText");
         }
         return confirmationText;
      }
      
      override public function setDifficultyLevel(level:int) : void
      {
         if(m_difficultyLevel == -1)
         {
            setInitialDifficultyLevel(level);
            MystreeReskinManagerWithEMH.getInstance(m_featureName).reloadStaicData(true);
            MystreeReskinManagerWithEMH.getInstance(m_featureName).openMystreeUI();
         }
         else if(MystreeReskinManagerWithEMH.getInstance(m_featureName).isStageComplete())
         {
            setDifficultyLevelForReplay(level);
            MystreeReskinManagerWithEMH.getInstance(m_featureName).reloadStaicData(false,true);
            MystreeReskinManagerWithEMH.getInstance(m_featureName).openMystreeUI();
         }
         else
         {
            switchDifficultyLevel(level);
            MystreeReskinManagerWithEMH.getInstance(m_featureName).reloadStaicData(false);
            MystreeReskinManagerWithEMH.getInstance(m_featureName).openMystreeUI();
         }
      }
      
      override public function openConfirmationWindow(callBack:Function = null, selectedDifficulty:String = null) : void
      {
         var m_switchConfirmationWindow:MystreeReskinSwitchConfirmationWindow = new MystreeReskinSwitchConfirmationWindow(confirmationDialog,m_featureName,callBack,this.getSwitchConfirmationBodyText(selectedDifficulty),ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"Yes"),ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"No"));
         UI.displayPopup(m_switchConfirmationWindow,false,"",true);
      }
   }
}

