package Classes.MOTD
{
   import Display.UI;
   import Engine.Managers.ErrorManager;
   import Widgets.Windows.CommunityGoalsWindow;
   import Widgets.Windows.MOTD.LemonAidV2Window;
   import Widgets.Windows.MOTD.SocialCharityWindow;
   import flash.display.DisplayObject;
   import flash.utils.getDefinitionByName;
   
   public class DialogMOTDHandler extends CustomWindowMOTDHandler
   {
      
      private static const CLASS_REFERENCES:Array = [SocialCharityWindow,LemonAidV2Window,CommunityGoalsWindow];
      
      private const DIALOG_CLASSNAME:String = "dialogClassname";
      
      private const DIALOG_BUILDING_NAME:String = "freeGift";
      
      public function DialogMOTDHandler(currentMOTD:Object)
      {
         super(currentMOTD);
      }
      
      override public function execute() : void
      {
         if(m_currentMOTD[this.DIALOG_CLASSNAME] != null)
         {
            this.acceptMOTD();
            m_isFinished = true;
         }
         else
         {
            ErrorManager.addError("Invalid MOTD declaraction, dialog Classname missing");
         }
      }
      
      override protected function acceptMOTD() : void
      {
         var windowClass:Class = null;
         var window:DisplayObject = null;
         super.acceptMOTD();
         try
         {
            windowClass = getDefinitionByName(m_currentMOTD[this.DIALOG_CLASSNAME]) as Class;
            window = m_currentMOTD[this.DIALOG_BUILDING_NAME] ? new windowClass(m_currentMOTD[this.DIALOG_BUILDING_NAME]) : new windowClass();
            UI.displayPopup(window);
         }
         catch(error:Error)
         {
            ErrorManager.addError("Class is not found: " + m_currentMOTD[DIALOG_CLASSNAME],ErrorManager.ERROR_FAILED_TO_LOAD);
         }
      }
   }
}

