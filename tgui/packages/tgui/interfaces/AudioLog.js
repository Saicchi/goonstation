/**
 * @file
 * @copyright 2022 Saicchi
 * @author Original Saicchi (https://github.com/Saicchi)
 * @license ISC
 */

import { useBackend } from '../backend';
import { Button, Box, Flex, Section } from '../components';
import { Window } from '../layouts';

export const PlayButton = (props) => {
    const {
        act,
        isrunning
    } = props;

    return (
        <Flex direction="column" align="center" backgroundColor="blue">
            <Button content="Stop" color="bad"
                disabled={!isrunning}
                onClick={() => { act("stop_device") }} />
        </Flex>
    )
};

export const RecordButton = (props) => {
    const {
        act,
        usemode
    } = props;

    return (
        <Button
            content={usemode ? "Playing" : "Recording"}
            color={usemode ? "good" : "average"}
            onClick={() => { act("toggle_mode") }} />
    )
};


export const AudioLog = (props, context) => {
    const { act, data } = useBackend(context);
    // Extract `health` and `color` variables from the `data` object.
    const {
        isrunning,
        usemode
    } = data;

    return (
        <Window>
            <Window.Content>
                <Section title="Stats">
                    <PlayButton act={act} isrunning={isrunning} />
                    <RecordButton act={act} usemode={usemode} />
                </Section>
            </Window.Content>
        </Window>
    );
}
