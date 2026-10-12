package Widgets.Windows.MOTD
{
   import Classes.Quest.PrerequisiteUtility;
   import Classes.util.MovieClipUtils;
   import Classes.util.ZLocUtils;
   import Managers.TemplateUIUtility;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.TextFields.FarmTextField;
   
   public class RoyaltyLoyaltyProgramMOTDWindow extends GenericSingleButtonWidgetMOTD
   {
      
      protected var m_close:Boolean = false;
      
      private var m_params:Object;
      
      public const ZRUNTIME_KEY_MOTD_ROYALTYLOYALTYPROGRAM_TITLE:String = "MOTD_ROYALTYLOYALTYPROGRAM_TITLE";
      
      public const ZRUNTIME_KEY_MOTD_ROYALTYLOYALTYPROGRAM_BODY:String = "MOTD_ROYALTYLOYALTYPROGRAM_BODY";
      
      public const ZRUNTIME_KEY_MOTD_ROYALTYLOYALTY_NPC_CALLOUT:String = "MOTD_ROYALTYLOYALTYPROGRAM_NPC_CALLOUT";
      
      public function RoyaltyLoyaltyProgramMOTDWindow(displayParams:Object = null)
      {
         this.m_params = displayParams;
         if(!displayParams)
         {
            displayParams = new Object();
            displayParams["dialog"] = "assets/dialogs/FV_motd_RoyaltyLoyaltyClub2016.swf";
         }
         super(displayParams);
      }
      
      override protected function postLoadComplete() : void
      {
         var titleText:String = null;
         var titleTextField:ZwTextField = null;
         var bodyText:String = null;
         var bodyTextField:ZwTextField = null;
         var calloutText:String = null;
         var calloutTextField:ZwTextField = null;
         if(m_window.hasOwnProperty("mainWindow"))
         {
            MovieClipUtils.recursivePlay(m_window);
            addWidget(new ZwBaseWidget(m_window.mainWindow));
            if(m_window.mainWindow["accept_bt"])
            {
               m_accept_bt = addWidget(new FarmAnimatedTextButton(m_window.mainWindow.accept_bt,ZLocUtils.t_pk("Dialogs:MOTD_RoyaltyLoyaltyProgram_ButtonText"),onAccept)) as FarmAnimatedTextButton;
            }
            if(Boolean(m_window.mainWindow["generic_mc"]) && Boolean(m_window.mainWindow.generic_mc["generic_bt"]))
            {
               m_accept_bt = addWidget(new FarmAnimatedTextButton(m_window.mainWindow.generic_mc.generic_bt,ZLocUtils.t_pk(m_currentMOTD["buttonText"]),onAccept)) as FarmAnimatedTextButton;
            }
            if(Boolean(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.MOTD)) && Boolean(m_window) && Boolean(m_window["mainWindow"]) && Boolean(m_window["mainWindow"]["buy_bt"]))
            {
               addWidget(new FarmAnimatedTextButton(m_window.mainWindow.buy_bt,ZLocUtils.t_pk(m_currentMOTD["buttonText"])),false);
               addWidget(new FarmAnimatedTextButton(m_window.mainWindow.share_bt,ZLocUtils.t_pk(m_currentMOTD["buttonText"])),false);
            }
            if(m_window.mainWindow["generic_tf"])
            {
               if(Global.flashHotParams.hasOwnProperty(this.ZRUNTIME_KEY_MOTD_ROYALTYLOYALTYPROGRAM_TITLE))
               {
                  titleText = String(Global.flashHotParams[this.ZRUNTIME_KEY_MOTD_ROYALTYLOYALTYPROGRAM_TITLE]);
               }
               titleTextField = new FarmTextField(m_window.mainWindow.generic_tf,titleText);
               addWidget(titleTextField);
               if(Boolean(this.m_params) && Boolean(this.m_params["textColor"]))
               {
                  TemplateUIUtility.applyTextColor(titleTextField,TemplateUIUtility.MOTD,this.m_params["textColor"]);
               }
            }
            if(m_window.mainWindow["generic1_tf"])
            {
               if(Global.flashHotParams.hasOwnProperty(this.ZRUNTIME_KEY_MOTD_ROYALTYLOYALTYPROGRAM_BODY))
               {
                  bodyText = String(Global.flashHotParams[this.ZRUNTIME_KEY_MOTD_ROYALTYLOYALTYPROGRAM_BODY]);
               }
               bodyTextField = new FarmTextField(m_window.mainWindow.generic1_tf,bodyText);
               addWidget(bodyTextField);
               if(Boolean(this.m_params) && Boolean(this.m_params["textColor"]))
               {
                  TemplateUIUtility.applyTextColor(bodyTextField,TemplateUIUtility.MOTD,this.m_params["textColor"]);
               }
            }
            if(m_window.mainWindow["callout_tf"])
            {
               if(Global.flashHotParams.hasOwnProperty(this.ZRUNTIME_KEY_MOTD_ROYALTYLOYALTY_NPC_CALLOUT))
               {
                  calloutText = String(Global.flashHotParams[this.ZRUNTIME_KEY_MOTD_ROYALTYLOYALTY_NPC_CALLOUT]);
               }
               calloutTextField = new FarmTextField(m_window.mainWindow.callout_tf,calloutText);
               if(Boolean(this.m_params) && Boolean(this.m_params["textColor"]))
               {
                  TemplateUIUtility.applyTextColor(calloutTextField,TemplateUIUtility.MOTD,this.m_params["textColor"]);
               }
            }
         }
      }
      
      override public function show() : void
      {
         if(!m_currentMOTD)
         {
            m_currentMOTD = new Object();
            m_currentMOTD["prereqs"] = null;
         }
         if(PrerequisiteUtility.arePrerequisitesMet(m_currentMOTD["prereqs"]))
         {
            super.show();
         }
         else
         {
            this.m_close = true;
            this.close();
         }
      }
   }
}

