package Widgets.Windows.MOTD
{
   import Classes.ZItem.FarmItem;
   import Managers.TemplateUIUtility;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   
   public class TemplatizedSingleButtonWidgetMOTD extends GenericSingleButtonWidgetMOTD
   {
      
      private var m_params:Object;
      
      public function TemplatizedSingleButtonWidgetMOTD(displayParams:Object = null)
      {
         super(displayParams);
         this.m_params = displayParams;
      }
      
      override protected function postLoadComplete() : void
      {
         var bonusAnimal:String = null;
         var bonusAnimalItem:FarmItem = null;
         var bonusTextField:ZwTextField = null;
         var bonusNameTextField:ZwTextField = null;
         super.postLoadComplete();
         var location:String = "";
         if(this.m_params["location"])
         {
            location = this.m_params["location"];
         }
         if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION,location))
         {
            TemplateUIUtility.applyExpansionTextColor(m_window.mainWindow.title_tf);
            TemplateUIUtility.applyExpansionBevelFilter(m_window.mainWindow.title_tf);
            TemplateUIUtility.applyExpansionDropShadowFilter(m_window.mainWindow.title_tf);
            TemplateUIUtility.applyExpansionSubTextColor(m_window.mainWindow.body_tf);
         }
         if(Boolean(m_window.mainWindow["bonus_tf"]) && Boolean(this.m_params["bonusAnimal"]))
         {
            bonusAnimal = this.m_params["bonusAnimal"];
            bonusAnimalItem = Global.farmGameSettingsManager.getFarmItemByName(bonusAnimal);
            if(bonusAnimalItem)
            {
               bonusTextField = new FarmTextField(m_window.mainWindow.bonus_tf,"BONUS ANIMAL!");
               addWidget(bonusTextField);
               bonusNameTextField = new FarmTextField(m_window.mainWindow.bonusname_tf,bonusAnimalItem.friendlyTitle);
               addWidget(bonusNameTextField);
               if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION,location))
               {
                  TemplateUIUtility.applyExpansionTextColor(m_window.mainWindow.bonus_tf);
                  TemplateUIUtility.applyExpansionBevelFilter(m_window.mainWindow.bonus_tf);
                  TemplateUIUtility.applyExpansionDropShadowFilter(m_window.mainWindow.bonus_tf);
                  TemplateUIUtility.applyExpansionSubTextColor(m_window.mainWindow.bonusname_tf);
               }
            }
         }
         if(Boolean(m_window.mainWindow.hasOwnProperty("mc_NPC")) && Boolean(this.m_params) && Boolean(this.m_params["npcUrl"]))
         {
            addWidget(new FarmIcon(m_window.mainWindow.mc_NPC,Global.getAssetURL(this.m_params["npcUrl"])));
         }
         if(Boolean(m_window.mainWindow.hasOwnProperty("mc_DoublePointStatue")) && Boolean(this.m_params) && Boolean(this.m_params["doubleStatueImagePath"]))
         {
            addWidget(new FarmIcon(m_window.mainWindow.mc_DoublePointStatue,Global.getAssetURL(this.m_params["doubleStatueImagePath"])));
         }
      }
   }
}

