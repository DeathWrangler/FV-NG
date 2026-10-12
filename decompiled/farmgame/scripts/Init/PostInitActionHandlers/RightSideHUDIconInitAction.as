package Init.PostInitActionHandlers
{
   public class RightSideHUDIconInitAction extends AbstractPostInitAction
   {
      
      protected var m_iconCode:String = "";
      
      public function RightSideHUDIconInitAction(iconCode:String, callback:Function = null)
      {
         this.m_iconCode = iconCode;
         super(callback);
      }
      
      override public function execute() : void
      {
         var queuedIconXML:XML = null;
         var iconName:String = null;
         var experimentName:String = null;
         var iconSeenFlag:String = null;
         if(this.m_iconCode != "" && this.m_iconCode != null)
         {
            queuedIconXML = Global.farmGameSettingsManager.getIconXMLByCode(this.m_iconCode);
            if(queuedIconXML != null)
            {
               iconName = queuedIconXML.@name.toString();
               experimentName = queuedIconXML.experiment.toString();
               if(Boolean(experimentName != "") && Boolean(Global.experimentManager.getExperimentVariant(experimentName)) || experimentName == "")
               {
                  iconSeenFlag = queuedIconXML.seenFlag.toString();
                  if(iconSeenFlag != "" && !Global.player.getSeenFlag(iconSeenFlag) || iconSeenFlag == "")
                  {
                     Global.hud.rightSideIconQueue.addIcon(iconName,queuedIconXML.priority.toString(),null,null,false);
                  }
               }
            }
         }
         m_isFinished = true;
      }
   }
}

