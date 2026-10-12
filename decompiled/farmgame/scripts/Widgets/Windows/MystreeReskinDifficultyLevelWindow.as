package Widgets.Windows
{
   import Classes.util.FarmGameUtil;
   import Display.HUD.HUD;
   import Managers.MystreeReskinDifficultyLevelsManager;
   import Managers.MystreeReskinManagerWithEMH;
   import Widgets.Core.TextFields.ZwTextField;
   
   public class MystreeReskinDifficultyLevelWindow extends DifficultyLevelWindow
   {
      
      public function MystreeReskinDifficultyLevelWindow(windowURL:String, featureName:String)
      {
         m_featureName = featureName;
         m_DifficultyLevelManager = MystreeReskinDifficultyLevelsManager.getInstance(m_featureName);
         m_windowName = MystreeReskinManagerWithEMH.getInstance(m_featureName).getWindowName();
         super(windowURL);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty("count_mc"))
         {
            m_count_mc = m_window.count_mc;
            m_count_mc.visible = true;
            m_count_tf = new ZwTextField(m_count_mc.count_tf,MystreeReskinManagerWithEMH.getInstance(m_featureName).getNumberOfBuckets());
         }
      }
      
      override protected function getExpiryDateText() : String
      {
         var result:String = "";
         var endDate:String = m_DifficultyLevelManager.getEndDate();
         var timeRemaining:Number = (FarmGameUtil.synchronizedDateToNumber(endDate) - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         if(MystreeReskinManagerWithEMH.getInstance(m_featureName).isFeatureInActivePeriod())
         {
            timeRemaining -= MystreeReskinManagerWithEMH.REDEEM_ADDITIONAL_DAYS * FarmGameUtil.NUM_SECS_IN_DAY;
         }
         var numDays:int = timeRemaining / FarmGameUtil.NUM_SECS_IN_DAY;
         if(!isNaN(timeRemaining))
         {
            if(numDays > 1)
            {
               result = numDays.toString() + " days left";
            }
            else
            {
               result = HUD.getformattedTimeLeft(timeRemaining) + " left";
            }
         }
         return result;
      }
      
      override protected function release() : void
      {
         super.release();
      }
      
      override public function resetStageButtons() : void
      {
         for(var i:int = 0; i < m_selectedButtonArray.length; i++)
         {
            if(MystreeReskinManagerWithEMH.getInstance(m_featureName).hasStageCompleted(i))
            {
               m_selectedButtonArray[i].visible = true;
               m_selectedButtonArray[i].checkmark_mc.visible = true;
            }
            else
            {
               m_selectedButtonArray[i].checkmark_mc.visible = false;
            }
         }
         super.resetStageButtons();
      }
   }
}

