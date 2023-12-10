import com.crazymaker.springcloud.hystrix.test.CircleAreaCalculatorCommand;
import com.netflix.hystrix.strategy.concurrency.HystrixRequestContext;
import org.junit.Test;
import static junit.framework.TestCase.*;

public class CircleAreaCalculatorCommandTest {
    @Test
    public void testWithoutCacheHits() throws Exception {
        HystrixRequestContext context = HystrixRequestContext.initializeContext();
        try {
            CircleAreaCalculatorCommand command1 = new CircleAreaCalculatorCommand(2.11);
            assertEquals(13.986684653047117, command1.execute());
            assertFalse(command1.isResponseFromCache());

            CircleAreaCalculatorCommand command2 = new CircleAreaCalculatorCommand(5.32);
            assertEquals(88.91461191895976, command2.execute());
            assertFalse(command2.isResponseFromCache());
        } finally {
            context.shutdown();
        }
    }

    @Test
    public void testWithCacheHits() throws Exception {
        HystrixRequestContext context = HystrixRequestContext.initializeContext();
        try {
            CircleAreaCalculatorCommand command1 = new CircleAreaCalculatorCommand(13.13);
            CircleAreaCalculatorCommand command2 = new CircleAreaCalculatorCommand(13.13);

            assertEquals(541.6008345416543, command1.execute());
            assertFalse(command1.isResponseFromCache());

            assertEquals(541.6008345416543, command2.execute());
            assertTrue(command2.isResponseFromCache());
        } finally {
            context.shutdown();
        }

        // start a new request context
        context = HystrixRequestContext.initializeContext();
        try {
            CircleAreaCalculatorCommand command3 = new CircleAreaCalculatorCommand(13.13);
            assertEquals(541.6008345416543, command3.execute());
            assertFalse(command3.isResponseFromCache());
        } finally {
            context.shutdown();
        }
    }

}
