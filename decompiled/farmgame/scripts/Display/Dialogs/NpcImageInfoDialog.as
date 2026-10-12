package Display.Dialogs
{
   import Display.FarmDynamicDialog;
   import com.troyer.widget.controller.BaseWidgetController;
   import com.troyer.widget.controller.ImageController;
   import com.troyer.widget.event.WidgetControllerEvent;
   import com.troyer.widget.view.BaseWidgetView;
   import com.troyer.widget.view.TextFieldView;
   
   public class NpcImageInfoDialog extends FarmDynamicDialog
   {
      
      public static const BUTTON_TEXT_IMPORT:String = "button_text_import";
      
      public static const SPEECH_TEXT_IMPORT:String = "speech_text_import";
      
      public static const NPC_ASSET_IMPORT:String = "npc_asset_import";
      
      public static const IMAGE_ASSET_IMPORT:String = "image_asset_import";
      
      public static const CALLBACK_IMPORT:String = "callback_import";
      
      private var m_imageWidth:Number = -1;
      
      private var m_avatarImageWidth:Number = -1;
      
      public function NpcImageInfoDialog(view:BaseWidgetView)
      {
         super(view);
      }
      
      override public function setup() : void
      {
         super.setup();
         this.setupImage();
         this.setupAvatarImage();
      }
      
      override protected function onContentLoaded(controller:BaseWidgetController) : void
      {
         var controllerName:String = controller.getName();
         if(controllerName == "image")
         {
            this.m_imageWidth = controller.getView().width;
            this.attemptSetupNpcSpeechBubble();
         }
         else if(controllerName == "npcImage")
         {
            this.m_avatarImageWidth = controller.getView().width;
            this.attemptSetupNpcSpeechBubble();
         }
      }
      
      private function setupImage() : void
      {
         var imageUrl:String = this.getImport(IMAGE_ASSET_IMPORT);
         this.setShortcutAttribute("image",ImageController.ATTRIBUTE_SOURCE,imageUrl);
      }
      
      private function setupAvatarImage() : void
      {
         var avatarAssetSrc:String = this.getImport(NPC_ASSET_IMPORT);
         this.getChildController("npcSpeechBubble").getChildController("npcImage").setAttribute(ImageController.ATTRIBUTE_SOURCE,avatarAssetSrc);
      }
      
      private function attemptSetupNpcSpeechBubble() : void
      {
         if(this.m_avatarImageWidth >= 0 && this.m_imageWidth >= 0)
         {
            this.setupNpcSpeechBubble(this.m_imageWidth - this.m_avatarImageWidth);
         }
      }
      
      private function setupNpcSpeechBubble(wrapWidth:Number) : void
      {
         var speechText:String = null;
         var buttonText:String = null;
         var bubbleGroupSubController:BaseWidgetController = this.getChildController("npcSpeechBubble").getChildController("bubbleGroup.mainBubble.mainBubblePos");
         if(bubbleGroupSubController != null)
         {
            bubbleGroupSubController.getChildController("bubbleText").setAttribute(TextFieldView.ATTRIBUTE_WRAP_WIDTH,wrapWidth);
            speechText = this.getImport(SPEECH_TEXT_IMPORT);
            bubbleGroupSubController.getChildController("bubbleText").setAttribute(TextFieldView.ATTRIBUTE_TEXT,speechText);
            buttonText = this.getImport(BUTTON_TEXT_IMPORT);
            bubbleGroupSubController.getChildController("okButton").setAttribute(TextFieldView.ATTRIBUTE_TEXT,buttonText);
            bubbleGroupSubController.getChildController("okButton").listen(WidgetControllerEvent.BUTTON_PRESSED,this.onButtonPress);
         }
      }
      
      private function onButtonPress(event:WidgetControllerEvent) : void
      {
         var callback:Function = this.getImport(CALLBACK_IMPORT);
         if(callback != null)
         {
            callback(event);
         }
      }
   }
}

