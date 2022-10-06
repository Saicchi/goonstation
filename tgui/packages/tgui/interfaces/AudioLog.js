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
        <Button ml="15%"
            content="Stop" color="bad"
            disabled={!isrunning}
            onClick={() => { act("stop_device") }} />
    )
};

export const ModeButton = (props) => {
    const {
        act,
        isrunning,
        usemode
    } = props;

    const recording = isrunning && usemode == 0;
    const playing = isrunning && !recording;

    return (
        <Flex mr="15%" >
            <Button
                content="AY"
                class={recording ? "AudioLog__ButtonGreenOn" : "AudioLog__ButtonGreenOff"}
                onClick={() => { act("toggle_mode") }} />
            <Button
                content="RECORD"
                class={playing ? "AudioLog__ButtonRedOn" : "AudioLog__ButtonRedOff"}
                onClick={() => { act("toggle_mode") }} />
        </Flex>
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
                <Section title="Control">
                    <Flex align="center" justify="space-between">
                        <PlayButton act={act} isrunning={isrunning} />
                        <ModeButton act={act} isrunning={isrunning} usemode={usemode} />
                    </Flex>
                </Section>
            </Window.Content>
        </Window>
    );
}
