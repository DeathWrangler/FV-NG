package Widgets.Windows.MOTD
{
   import Classes.Constants.Experiments;
   import Managers.TemplateUIUtility;
   import Widgets.Buttons.FarmButton;
   
   public class GenericCloseButtonWidgetMOTD extends GenericSingleButtonWidgetMOTD
   {
      
      private var m_params:Object;
      
      public function GenericCloseButtonWidgetMOTD(displayParams:Object = null)
      {
         var dialog:String = null;
         var motd:Object = null;
         this.m_params = displayParams;
         if(Boolean(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.MOTD)) && Boolean(this.m_params) && Boolean(this.m_params["textColor"]) && Boolean(this.m_params["dialogBackground"]))
         {
            if(this.m_params.hasOwnProperty("templateDialog"))
            {
               dialog = this.m_params["templateDialog"];
            }
            else
            {
               dialog = TemplateUIUtility.MOTD_TEMPLATE_SWF;
               this.m_params["dialog"] = dialog;
            }
         }
         else if(Boolean(displayParams) && Boolean(displayParams["dialog"]))
         {
            dialog = displayParams["dialog"];
         }
         else
         {
            motd = Global.player.currentMOTD;
            dialog = motd["dialog"];
         }
         super(displayParams);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(Global.eosManager.getEosVariant(Experiments.EXPERIMENT_FLASH_MOTD_EXP) >= 2)
         {
            if(!m_closeButton)
            {
               if(Boolean(m_window.mainWindow) && Boolean(m_window.mainWindow.close_bt))
               {
                  m_closeButton = addWidget(new FarmButton(m_window.mainWindow.close_bt,onClose)) as FarmButton;
               }
            }
            else
            {
               if(m_closeButton)
               {
                  m_closeButton.visible = true;
               }
               if(Boolean(m_window.mainWindow) && Boolean(m_window.mainWindow.close_bt))
               {
                  m_window.mainWindow.close_bt.visible = true;
               }
            }
         }
         else if(m_closeButton)
         {
            m_closeButton.visible = false;
         }
         else if(Boolean(m_window.mainWindow) && Boolean(m_window.mainWindow.close_bt))
         {
            m_window.mainWindow.close_bt.visible = false;
         }
      }
   }
}

