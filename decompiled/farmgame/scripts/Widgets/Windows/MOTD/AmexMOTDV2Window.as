package Widgets.Windows.MOTD
{
   import Classes.util.ZLocUtils;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.TextFields.FarmTextField;
   import flash.text.TextField;
   
   public class AmexMOTDV2Window extends GenericSingleButtonWidgetMOTD
   {
      
      public function AmexMOTDV2Window(displayParams:Object = null)
      {
         super(displayParams);
      }
      
      override protected function postLoadComplete() : void
      {
         addWidget(new ZwButton(m_window.generic_bt,onAccept));
         if(m_currentMOTD["button"] != null && Boolean(m_window.generic_bt.hasOwnProperty("generic_tf")))
         {
            (m_window.generic_bt.generic_tf as TextField).text = ZLocUtils.t_pk(m_currentMOTD["button"]);
         }
         if(m_window.hasOwnProperty("headline_tf"))
         {
            addWidget(new FarmTextField(m_window.headline_tf,ZLocUtils.t_pk(m_currentMOTD["title"])));
         }
         if(m_window.hasOwnProperty("subhead_tf"))
         {
            addWidget(new FarmTextField(m_window.subhead_tf,ZLocUtils.t_pk(m_currentMOTD["subtitle"])));
         }
         if(m_window.hasOwnProperty("bodycopy_tf"))
         {
            addWidget(new FarmTextField(m_window.bodycopy_tf,ZLocUtils.t_pk(m_currentMOTD["text"])));
         }
         if(m_window.hasOwnProperty("legal_tf"))
         {
            addWidget(new FarmTextField(m_window.legal_tf,ZLocUtils.t_pk(m_currentMOTD["legal"])));
         }
      }
   }
}

