package Init.PostInitActionHandlers
{
   import Classes.Quest.PrerequisiteUtility;
   import Classes.XmlDrivenAction;
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsManager;
   import Widgets.Windows.WorldProgressWindow;
   import flash.events.Event;
   
   public class WorldProgressWindowInitAction extends AbstractPostInitAction
   {
      
      public var m_worldPrefix:String = null;
      
      public function WorldProgressWindowInitAction(worldPrefix:String = null, callback:Function = null)
      {
         super(callback);
         this.m_worldPrefix = worldPrefix;
      }
      
      override public function execute() : void
      {
         this.conditionalyExecute(null);
      }
      
      public function conditionalyExecute(event:Event = null) : void
      {
         var autoShow:Boolean = false;
         if(FeatureOptionsManager.getInstance().loaded)
         {
            if(WorldProgressWindow.shouldShowOnWorldLoad(this.m_worldPrefix))
            {
               if(!WorldProgressWindow.userHasSkippedViewOnFirstWorldLoad(this.m_worldPrefix))
               {
                  WorldProgressWindow.setUserHasSkippedViewOnFirstWorldLoad(this.m_worldPrefix);
               }
               else
               {
                  autoShow = WorldProgressWindow.userHasAutoShowCheckboxOn();
                  FarmStatsManager.sample(100,"exp_map_dialog",Global.worldManager.currentWorldType,"at_world_load","checkbox_show_" + (autoShow ? "startup" : "no"));
                  this.actualExecute();
               }
            }
            if(FeatureOptionsManager.getInstance().hasEventListener(FeatureOptionsManager.EVENT_FEATURE_OPTIONS_LOADED))
            {
               FeatureOptionsManager.getInstance().removeEventListener(FeatureOptionsManager.EVENT_FEATURE_OPTIONS_LOADED,this.conditionalyExecute);
            }
            m_isFinished = true;
         }
         else
         {
            FeatureOptionsManager.getInstance().addEventListener(FeatureOptionsManager.EVENT_FEATURE_OPTIONS_LOADED,this.conditionalyExecute);
         }
      }
      
      public function actualExecute() : void
      {
         var actionMenuConfig:XML = null;
         var buttons:XMLList = null;
         var button:XML = null;
         var action:XmlDrivenAction = null;
         var config:Object = Global.worldSettingsManager.getConfigByWorld(Global.worldManager.currentWorldType);
         var actionMenuConfigs:XMLList = config.actionMenuConfig as XMLList;
         if(Boolean(actionMenuConfigs) && actionMenuConfigs.length() > 0)
         {
            for each(actionMenuConfig in actionMenuConfigs)
            {
               buttons = actionMenuConfig.button as XMLList;
               if(Boolean(buttons) && buttons.length() > 0)
               {
                  for each(button in buttons)
                  {
                     if(button.hasOwnProperty("@name") && button["@name"] == "WorldProgress")
                     {
                        if(button.hasOwnProperty("prereqs"))
                        {
                           if(!PrerequisiteUtility.evalPrereqsXML(button.prereqs.prereq as XMLList))
                           {
                              continue;
                           }
                        }
                        action = new XmlDrivenAction(button.action[0]);
                        action.act();
                     }
                  }
               }
            }
         }
      }
   }
}

