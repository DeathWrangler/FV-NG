package Classes.MOTD
{
   import Classes.util.ZLocUtils;
   import Display.DataDrivenOkayPopup;
   import Display.UI;
   
   public class BaseDialogMOTDHandler extends MOTDHandler
   {
      
      protected static const MOTD_DIALOG_NAME_NORMAL:String = "motd_BaseDialog";
      
      public function BaseDialogMOTDHandler(currentMOTD:Object)
      {
         super(currentMOTD);
      }
      
      override public function execute() : void
      {
         var dialog:String = MOTD_DIALOG_NAME_NORMAL;
         if(m_currentMOTD.hasOwnProperty("dialog"))
         {
            dialog = m_currentMOTD["dialog"];
         }
         var params:Array = [m_currentMOTD["icon"].toString(),ZLocUtils.t_pk(m_currentMOTD["text"])];
         if(m_currentMOTD.hasOwnProperty("title"))
         {
            if(ZLocUtils.isObject(m_currentMOTD["title"]))
            {
               params.push(ZLocUtils.tk_pk_asTitle(m_currentMOTD["title"]));
            }
            else
            {
               params.push(ZLocUtils.t_pk(m_currentMOTD["title"]));
            }
         }
         if(m_currentMOTD.hasOwnProperty("buttonText"))
         {
            params.push(ZLocUtils.t_pk(m_currentMOTD["buttonText"]));
         }
         if(m_currentMOTD.hasOwnProperty("cancelButtonText"))
         {
            params.push(ZLocUtils.t_pk(m_currentMOTD["cancelButtonText"]));
         }
         var displayPopup:DataDrivenOkayPopup = new DataDrivenOkayPopup(dialog,params,acceptMOTD);
         UI.displayPopup(displayPopup,false);
         super.execute();
      }
   }
}

