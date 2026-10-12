package Init.PostInitActionHandlers
{
   public class PostInitFunctionCall extends AbstractPostInitAction
   {
      
      private var m_data:Object = null;
      
      public function PostInitFunctionCall(callback:Function = null, data:Object = null)
      {
         super(callback);
         this.m_data = data;
      }
      
      override public function execute() : void
      {
         if(m_callback != null)
         {
            if(this.m_data != null)
            {
               m_callback(this.m_data);
            }
            else
            {
               m_callback();
            }
         }
         m_isFinished = true;
      }
   }
}

