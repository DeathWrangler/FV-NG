package Display.Dialogs
{
   import Classes.util.ZLocUtils;
   import Display.FarmDynamicDialog;
   import com.troyer.widget.view.BaseWidgetView;
   import com.troyer.widget.view.TextFieldView;
   
   public class SmartPopupMarketing extends FarmDynamicDialog
   {
      
      private var m_trackerKey:String;
      
      public function SmartPopupMarketing(view:BaseWidgetView)
      {
         super(view);
      }
      
      override public function setup() : void
      {
         super.setup();
         this.setShortcutAttribute("bodyText",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","SmartPopupsMarketingText"));
         this.setShortcutAttribute("showFewerText",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","SmartPopupsMarketingShowFewer"));
         this.setShortcutAttribute("cancelText",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","Cancel"));
      }
      
      public function setTrackerKey(trackerKey:String) : void
      {
         this.m_trackerKey = trackerKey;
      }
      
      public function getTrackerKey() : String
      {
         return this.m_trackerKey;
      }
   }
}

